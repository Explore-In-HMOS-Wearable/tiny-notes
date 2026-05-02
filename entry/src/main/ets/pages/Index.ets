import { ArcList, ArcListItem, ArcSwiper, promptAction } from '@kit.ArkUI';
import { formBindingData, formProvider } from '@kit.FormKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PreferencesUtil } from '../utils/PreferencesUtils';
import { NotesRepository } from '../data/NotesRepository';
import { NotesDataSource } from '../data/NotesDataSource';
import { Note } from '../model/Note';
import { StorageKeys } from '../constants/StorageKeys';
import { NoteComposer } from '../components/NoteComposer';
import { NoteDetailSheet } from '../components/NoteDetailSheet';
import { NoteListItem } from '../components/NoteListItem';
import { Logger } from '../utils/Logger';
import { Haptics } from '../utils/Haptics';
import { Reminders, ReminderPreset } from '../service/Reminders';

const TAG = 'IndexPage';

@Entry
@Component
struct TinyNotesPage {
  @State noteInput: string = '';
  @State searchQuery: string = '';
  @State selectedNoteId: string = '';
  @State editingNoteId: string = '';
  @State editingText: string = '';
  @State sheetOpen: boolean = false;
  @State activeNote: Note | null = null;
  @State notesCount: number = 0;
  @State totalCount: number = 0;
  @State sheetMode: string = 'view';
  private context: Context = AppStorage.get('context') as Context;
  private repo: NotesRepository = NotesRepository.getInstance();
  private dataSource: NotesDataSource = new NotesDataSource();
  private allNotes: Note[] = [];
  private formIdsCache: string[] = [];
  private readonly handleNoteInputChange = (value: string): void => {
    this.noteInput = value;
  };
  private readonly handleAddNote = (): void => { void this.addNote(); };
  private readonly handleSearchQueryChange = (value: string): void => {
    this.searchQuery = value;
    this.applyFilter();
  };
  private readonly handleClearSearch = (): void => {
    this.searchQuery = '';
    this.applyFilter();
  };
  private readonly handleOpenSheet = (note: Note): void => this.openSheet(note);
  private readonly handlePinNote = (note: Note): void => { void this.pinNote(note); };
  private readonly handleDeleteRequest = (note: Note): void => this.confirmDelete(note);

  aboutToAppear(): void {
    this.initialize().catch((err: Error) => Logger.error(TAG, `initialize err: ${err.message}`));
  }

  private async initialize(): Promise<void> {
    if (!this.context) {
      return;
    }
    await Promise.all([
      this.refresh(),
      this.loadFormIds()
    ]);
    await this.loadPinned();
  }

  private openReminderPicker(note: Note): void {
    this.activeNote = note;
    this.sheetMode = 'reminder';
    this.sheetOpen = true;
  }

  private async scheduleReminder(note: Note, preset: ReminderPreset): Promise<void> {
    Haptics.tap();
    const id = await Reminders.schedule(this.context, note.text, preset);
    if (id !== null) {
      const updated = await this.repo.addReminderId(this.context, note.id, id);
      if (updated) {
        const idx = this.allNotes.findIndex(n => n.id === note.id);
        if (idx >= 0) {
          this.allNotes[idx] = updated;
        }
        this.dataSource.updateById(note.id, updated);
        if (this.activeNote && this.activeNote.id === note.id) {
          this.activeNote = updated;
        }
      }
      this.sheetMode = 'view';
      this.toast($r('app.string.toast_reminder_set'));
    } else {
      this.sheetMode = 'view';
      this.toast($r('app.string.toast_reminder_failed'));
    }
  }

  private async refresh(): Promise<void> {
    if (!this.context) {
      return;
    }
    this.allNotes = await this.repo.load(this.context);
    this.applyFilter();
  }

  private applyFilter(): void {
    const q = this.searchQuery.trim().toLowerCase();
    const filtered = q.length > 0
      ? this.allNotes.filter(n => n.text.toLowerCase().indexOf(q) >= 0)
      : this.allNotes;
    this.dataSource.reload(filtered);
    this.notesCount = filtered.length;
    this.totalCount = this.allNotes.length;
  }

  private async loadFormIds(): Promise<void> {
    const raw = await PreferencesUtil.getInstance().getJson<string[]>(this.context, StorageKeys.FORM_IDS, []);
    if (Array.isArray(raw) && raw.length > 0) {
      this.formIdsCache = raw.filter((item: string) => typeof item === 'string' && item.length > 0);
      return;
    }

    const legacy = await PreferencesUtil.getInstance().getValue(this.context, StorageKeys.FORM_ID, '');
    if (typeof legacy === 'string' && legacy.length > 0) {
      this.formIdsCache = [legacy];
      await PreferencesUtil.getInstance().putJson(this.context, StorageKeys.FORM_IDS, this.formIdsCache);
      return;
    }

    this.formIdsCache = [];
  }

  private async loadPinned(): Promise<void> {
    const v = await PreferencesUtil.getInstance().getValue(this.context, StorageKeys.PINNED_NOTE_ID, '');
    const pinnedNoteId = typeof v === 'string' ? v : '';
    if (pinnedNoteId && !this.allNotes.some(note => note.id === pinnedNoteId)) {
      await this.clearPinnedState();
      return;
    }
    this.selectedNoteId = pinnedNoteId;
  }

  private async addNote(): Promise<void> {
    const text = this.noteInput.trim();
    if (!text) {
      return;
    }
    const result = await this.repo.add(this.context, text);
    this.allNotes = result.notes;
    this.applyFilter();
    if (result.duplicate) {
      this.toast($r('app.string.toast_duplicate'));
      return;
    }
    Haptics.tap();
    this.noteInput = '';
    this.toast($r('app.string.toast_swipe_to_see'));
  }

  private async pinNote(note: Note): Promise<void> {
    Haptics.tap();
    await this.setPinnedState(note);
    this.toast($r('app.string.toast_pinned'));
  }

  private async deleteNote(note: Note): Promise<void> {
    Haptics.strong();
    const wasPinned = this.selectedNoteId === note.id;
    for (const reminderId of note.reminderIds) {
      await Reminders.cancel(reminderId);
    }
    await this.repo.remove(this.context, note.id);
    this.allNotes = this.allNotes.filter(n => n.id !== note.id);
    this.dataSource.removeById(note.id);
    this.notesCount = this.dataSource.totalCount();
    this.totalCount = this.allNotes.length;
    if (wasPinned) {
      await this.clearPinnedState();
    }
    this.closeSheet();
  }

  private confirmDelete(note: Note): void {
    this.activeNote = note;
    this.sheetMode = 'delete';
    this.sheetOpen = true;
  }

  private async setPinnedState(note: Note): Promise<void> {
    this.selectedNoteId = note.id;
    await Promise.all([
      this.repo.pin(this.context, note.text),
      PreferencesUtil.getInstance().putValue(this.context, StorageKeys.PINNED_NOTE_ID, note.id)
    ]);
    await this.updateWidgetText(note.text);
  }

  private async clearPinnedState(): Promise<void> {
    this.selectedNoteId = '';
    await this.repo.clearPin(this.context);
    await this.updateWidgetText('');
  }

  private async updateWidgetText(text: string): Promise<void> {
    if (this.formIdsCache.length === 0) {
      return;
    }

    const activeFormIds: string[] = [];
    for (const formId of this.formIdsCache) {
      try {
        const data = formBindingData.createFormBindingData({ text });
        await formProvider.updateForm(formId, data);
        activeFormIds.push(formId);
      } catch (e) {
        const err = e as BusinessError;
        Logger.error(TAG, `updateForm err formId=${formId} code=${err.code} msg=${err.message}`);
      }
    }

    this.formIdsCache = activeFormIds;
    if (activeFormIds.length > 0) {
      await Promise.all([
        PreferencesUtil.getInstance().putJson(this.context, StorageKeys.FORM_IDS, activeFormIds),
        PreferencesUtil
          .getInstance()
          .putValue(this.context, StorageKeys.FORM_ID, activeFormIds[activeFormIds.length - 1])
      ]);
    } else {
      await Promise.all([
        PreferencesUtil.getInstance().remove(this.context, StorageKeys.FORM_IDS),
        PreferencesUtil.getInstance().remove(this.context, StorageKeys.FORM_ID)
      ]);
    }
  }

  private openEdit(note: Note): void {
    this.editingNoteId = note.id;
    this.editingText = note.text;
    this.sheetMode = 'edit';
  }

  private async saveEdit(): Promise<void> {
    if (!this.editingNoteId) {
      return;
    }
    const id = this.editingNoteId;
    this.allNotes = await this.repo.update(this.context, id, this.editingText);
    const updated = this.allNotes.find(n => n.id === id);
    if (updated) {
      this.dataSource.updateById(id, updated);
      if (this.selectedNoteId === id) {
        await this.pinNote(updated);
      }
    }
    this.applyFilter();
    this.editingNoteId = '';
    this.editingText = '';
    this.closeSheet();
  }

  private cancelEdit(): void {
    this.editingNoteId = '';
    this.editingText = '';
    this.sheetMode = 'view';
  }

  private openSheet(note: Note): void {
    this.activeNote = note;
    this.sheetMode = 'view';
    this.sheetOpen = true;
  }

  private closeSheet(): void {
    this.sheetOpen = false;
    this.sheetMode = 'view';
    this.activeNote = null;
    this.cancelEdit();
  }

  private toast(msg: Resource | string): void {
    try {
      promptAction.openToast({ message: msg, duration: 1400 });
    } catch (e) {
      const err = e as Error;
      Logger.error(TAG, `toast err: ${err.message}`);
    }
  }

  @Builder
  private detailSheetBuilder(): void {
    NoteDetailSheet({
      activeNote: this.activeNote,
      mode: this.sheetMode,
      editingNoteId: this.editingNoteId,
      editingText: this.editingText,
      context: this.context,
      onEditingTextChange: (value: string): void => {
        this.editingText = value;
      },
      onSaveEdit: (): void => {
        void this.saveEdit();
      },
      onCancelEdit: (): void => {
        this.cancelEdit();
      },
      onOpenEdit: (note: Note): void => {
        this.openEdit(note);
      },
      onOpenReminderPicker: (note: Note): void => {
        this.openReminderPicker(note);
      },
      onPickReminder: (preset: string): void => {
        if (this.activeNote) {
          void this.scheduleReminder(this.activeNote, preset as ReminderPreset);
        }
      },
      onBackToDetail: (): void => {
        this.sheetMode = 'view';
      },
      onConfirmDelete: (note: Note): void => {
        if (this.sheetMode === 'delete') {
          void this.deleteNote(note);
          return;
        }
        this.confirmDelete(note);
      }
    })
  }

  build() {
    ArcSwiper() {
      NoteComposer({
        noteInput: this.noteInput,
        onInputChange: this.handleNoteInputChange,
        onSubmit: this.handleAddNote
      })

      ArcList({ initialIndex: 1 }) {
        ArcListItem() {
          Image($r('app.media.sticky_note')).width(40)
        }

        ArcListItem() {
          Column() {
            Text($r('app.string.all_notes_title_count', this.totalCount))
              .fontSize(16)
              .margin({ top: 8 })
              .fontColor($r('app.color.brand_primary'))
            Text($r('app.string.all_notes_hint'))
              .fontSize(10)
              .margin({ top: 2, bottom: 8 })
              .fontColor($r('app.color.brand_primary'))
          }
        }

        if (this.totalCount > 0) {
          ArcListItem() {
            Row() {
              TextInput({ text: this.searchQuery, placeholder: $r('app.string.search_placeholder') })
                .onChange(this.handleSearchQueryChange)
                .layoutWeight(1)
                .height(34)
                .backgroundColor($r('app.color.field_surface'))
                .borderWidth(1)
                .borderColor($r('app.color.field_border'))
                .borderRadius(17)
                .padding({ left: 12, right: 12 })
                .fontColor($r('app.color.on_surface'))
                .fontSize(12)
                .placeholderFont({ size: 11 })

              if (this.searchQuery.length > 0) {
                Row() {
                  Text('×')
                    .fontSize(13)
                    .fontColor($r('app.color.on_surface'))
                }
                  .onClick(this.handleClearSearch)
                  .accessibilityText($r('app.string.a11y_clear_search'))
                  .backgroundColor($r('app.color.field_surface'))
                  .borderWidth(1)
                  .borderColor($r('app.color.field_border'))
                  .height(28)
                  .width(28)
                  .borderRadius(14)
                  .justifyContent(FlexAlign.Center)
                  .margin({ left: 4 })
              }
            }
            .width('92%')
            .margin({ top: 4, bottom: 6 })
          }
        }

        if (this.notesCount === 0) {
          ArcListItem() {
            Column() {
              Text($r('app.string.empty_notes_title'))
                .fontSize(13)
                .fontColor($r('app.color.on_surface'))
                .margin({ top: 8 })
              Text($r('app.string.empty_notes_hint'))
                .fontSize(10)
                .fontColor($r('app.color.on_surface_muted'))
                .margin({ top: 2, bottom: 8 })
            }
          }
        }

        LazyForEach(this.dataSource, (item: Note) => {
          NoteListItem({
            note: item,
            isSelected: this.selectedNoteId === item.id,
            onOpenNote: this.handleOpenSheet,
            onPinNote: this.handlePinNote,
            onRequestDelete: this.handleDeleteRequest
          })
        }, (item: Note) => item.id)
      }
    }
    .bindSheet($$this.sheetOpen, this.detailSheetBuilder(), {
      height: SheetSize.MEDIUM,
      onDisappear: (): void => {
        this.closeSheet();
      }
    })
  }
}
