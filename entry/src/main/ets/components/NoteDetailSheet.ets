import { Limits } from '../constants/StorageKeys';
import { Note } from '../model/Note';
import { formatRelative } from '../utils/DateFormat';

@Component
export struct NoteDetailSheet {
  @Prop activeNote: Note | null = null;
  @Prop mode: string = 'view';
  @Prop editingNoteId: string = '';
  @Prop editingText: string = '';
  context: Context = AppStorage.get('context') as Context;
  onEditingTextChange: (value: string) => void = () => {};
  onSaveEdit: () => void = () => {};
  onCancelEdit: () => void = () => {};
  onOpenEdit: (note: Note) => void = () => {};
  onOpenReminderPicker: (note: Note) => void = () => {};
  onConfirmDelete: (note: Note) => void = () => {};
  onPickReminder: (preset: string) => void = () => {};
  onBackToDetail: () => void = () => {};
  private readonly handleEditingTextChange = (value: string): void => this.onEditingTextChange(value);
  private readonly handleSaveEdit = (): void => this.onSaveEdit();
  private readonly handleCancelEdit = (): void => this.onCancelEdit();
  private readonly handleBackToDetail = (): void => this.onBackToDetail();
  private readonly handleDelete = (): void => {
    if (this.activeNote) {
      this.onConfirmDelete(this.activeNote);
    }
  };
  private readonly handleOpenEdit = (): void => {
    if (this.activeNote) {
      this.onOpenEdit(this.activeNote);
    }
  };
  private readonly handleOpenReminderPicker = (): void => {
    if (this.activeNote) {
      this.onOpenReminderPicker(this.activeNote);
    }
  };
  private readonly handlePickReminder1h = (): void => this.onPickReminder('1h');
  private readonly handlePickReminder1d = (): void => this.onPickReminder('1d');
  private readonly handlePickReminder1w = (): void => this.onPickReminder('1w');

  build() {
    Column() {
      if (this.activeNote) {
        if (this.mode === 'delete') {
          Text($r('app.string.confirm_delete_title'))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_surface'))
            .margin({ top: 10, bottom: 4 })
          Text($r('app.string.confirm_delete_msg'))
            .fontSize(10)
            .fontColor($r('app.color.on_surface_muted'))
            .margin({ bottom: 10 })
          Row() {
            Row() {
              Text($r('app.string.action_cancel'))
                .fontSize(10)
                .fontColor($r('app.color.on_surface'))
            }
            .onClick(this.handleBackToDetail)
            .backgroundColor($r('app.color.surface_muted'))
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
            .justifyContent(FlexAlign.Center)
            .margin(4)
            Row() {
              Text($r('app.string.action_delete'))
                .fontSize(10)
                .fontColor($r('app.color.on_danger'))
            }
            .onClick(this.handleDelete)
            .backgroundColor($r('app.color.danger'))
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
            .justifyContent(FlexAlign.Center)
            .margin(4)
          }
          .margin({ bottom: 10 })
        } else if (this.mode === 'reminder') {
          Text($r('app.string.action_remind'))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_surface'))
            .margin({ top: 10, bottom: 8 })
          Row() {
            Text($r('app.string.remind_in_1h'))
              .fontSize(10)
              .fontColor($r('app.color.on_surface'))
          }
          .onClick(this.handlePickReminder1h)
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(13)
          .height(26)
          .padding({ left: 12, right: 12 })
          .justifyContent(FlexAlign.Center)
          .margin(3)
          Row() {
            Text($r('app.string.remind_in_1d'))
              .fontSize(10)
              .fontColor($r('app.color.on_surface'))
          }
          .onClick(this.handlePickReminder1d)
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(13)
          .height(26)
          .padding({ left: 12, right: 12 })
          .justifyContent(FlexAlign.Center)
          .margin(3)
          Row() {
            Text($r('app.string.remind_in_1w'))
              .fontSize(10)
              .fontColor($r('app.color.on_surface'))
          }
          .onClick(this.handlePickReminder1w)
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(13)
          .height(26)
          .padding({ left: 12, right: 12 })
          .justifyContent(FlexAlign.Center)
          .margin(3)
          Row() {
            Text($r('app.string.action_cancel'))
              .fontSize(10)
              .fontColor($r('app.color.on_surface'))
          }
          .onClick(this.handleBackToDetail)
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(12)
          .height(24)
          .padding({ left: 12, right: 12 })
          .justifyContent(FlexAlign.Center)
          .margin({ top: 6, bottom: 10 })
        } else if (this.editingNoteId === this.activeNote.id) {
          TextInput({ text: this.editingText })
            .maxLength(Limits.NOTE_MAX_LENGTH)
            .onChange(this.handleEditingTextChange)
            .onSubmit(this.handleSaveEdit)
            .cancelButton({ style: CancelButtonStyle.INVISIBLE })
            .fontSize(14)
            .margin({ top: 8, bottom: 4 })
            .width('90%')
          Text(`${this.editingText.length}/${Limits.NOTE_MAX_LENGTH}`)
            .fontSize(9)
            .fontColor($r('app.color.on_surface_muted'))
            .margin({ bottom: 6 })
          Row() {
            Row() {
              Text($r('app.string.action_cancel'))
                .fontSize(10)
                .fontColor($r('app.color.on_surface'))
            }
              .onClick(this.handleCancelEdit)
              .backgroundColor($r('app.color.surface_muted'))
              .borderRadius(14)
              .height(28)
              .padding({ left: 12, right: 12 })
              .justifyContent(FlexAlign.Center)
              .margin(4)
            Row() {
              Text($r('app.string.action_save'))
                .fontSize(10)
                .fontColor($r('app.color.on_primary'))
            }
              .onClick(this.handleSaveEdit)
              .backgroundColor($r('app.color.brand_accent'))
              .borderRadius(14)
              .height(28)
              .padding({ left: 12, right: 12 })
              .justifyContent(FlexAlign.Center)
              .margin(4)
          }
        } else {
          Text(this.activeNote.text)
            .fontSize(13)
            .fontColor($r('app.color.on_surface'))
            .padding(8)
            .width('90%')
          Text(formatRelative(this.context, this.activeNote.updatedAt))
            .fontSize(9)
            .fontColor($r('app.color.on_surface_muted'))
            .margin({ bottom: 6 })
          Row() {
            Row() {
              Text($r('app.string.action_edit'))
                .fontSize(10)
                .fontColor($r('app.color.on_surface'))
            }
              .onClick(this.handleOpenEdit)
              .backgroundColor($r('app.color.surface_muted'))
              .borderRadius(14)
              .height(28)
              .padding({ left: 12, right: 12 })
              .justifyContent(FlexAlign.Center)
              .margin(4)
            Row() {
              Text($r('app.string.action_remind'))
                .fontSize(10)
                .fontColor($r('app.color.on_primary'))
            }
              .onClick(this.handleOpenReminderPicker)
              .backgroundColor($r('app.color.brand_accent'))
              .borderRadius(14)
              .height(28)
              .padding({ left: 12, right: 12 })
              .justifyContent(FlexAlign.Center)
              .margin(4)
            Row() {
              Text($r('app.string.action_delete'))
                .fontSize(10)
                .fontColor($r('app.color.on_danger'))
            }
              .onClick(this.handleDelete)
              .backgroundColor($r('app.color.danger'))
              .borderRadius(14)
              .height(28)
              .padding({ left: 12, right: 12 })
              .justifyContent(FlexAlign.Center)
              .margin(4)
          }
        }
      }
    }
    .width('100%')
    .padding(8)
  }
}
