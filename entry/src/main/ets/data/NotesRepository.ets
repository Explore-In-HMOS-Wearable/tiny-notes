import { Note, createNote, isNormalizedNote, normalizeNote } from '../model/Note';
import { PreferencesUtil } from '../utils/PreferencesUtils';
import { Limits, StorageKeys } from '../constants/StorageKeys';

export interface AddResult {
  notes: Note[];
  added: boolean;
  duplicate: boolean;
}

export class NotesRepository {
  private static instance: NotesRepository;

  static getInstance(): NotesRepository {
    if (!NotesRepository.instance) {
      NotesRepository.instance = new NotesRepository();
    }
    return NotesRepository.instance;
  }

  async load(context: Context): Promise<Note[]> {
    const raw = await PreferencesUtil.getInstance().getJson<Array<Note | string>>(context, StorageKeys.NOTES, []);
    const items = Array.isArray(raw) ? raw : [];
    let migrated = false;
    const total = items.length;
    const notes: Note[] = [];

    items.forEach((item, index) => {
      const fallbackTime = Date.now() - ((total - index) * 1000);
      const normalized = normalizeNote(item, fallbackTime);
      if (normalized) {
        notes.push(normalized);
      }
      if (!isNormalizedNote(item)) {
        migrated = true;
      }
    });

    const sorted = notes.sort((a, b) => b.updatedAt - a.updatedAt);
    if (migrated) {
      await this.save(context, sorted);
    }
    return sorted;
  }

  private async save(context: Context, notes: Note[]): Promise<void> {
    await PreferencesUtil.getInstance().putJson<Note[]>(context, StorageKeys.NOTES, notes);
  }

  async add(context: Context, text: string, allowDuplicate: boolean = false): Promise<AddResult> {
    const trimmed = text.trim();
    if (!trimmed) {
      return { notes: await this.load(context), added: false, duplicate: false };
    }
    const clipped = trimmed.slice(0, Limits.NOTE_MAX_LENGTH);
    const notes = await this.load(context);
    if (!allowDuplicate && notes.some(n => n.text === clipped)) {
      return { notes, added: false, duplicate: true };
    }
    if (notes.length >= Limits.NOTES_MAX_COUNT) {
      notes.pop();
    }
    notes.unshift(createNote(clipped));
    await this.save(context, notes);
    return { notes, added: true, duplicate: false };
  }

  async remove(context: Context, id: string): Promise<Note[]> {
    const notes = (await this.load(context)).filter(n => n.id !== id);
    await this.save(context, notes);
    return notes;
  }

  async update(context: Context, id: string, text: string): Promise<Note[]> {
    const trimmed = text.trim().slice(0, Limits.NOTE_MAX_LENGTH);
    if (!trimmed) {
      return await this.load(context);
    }
    const notes = await this.load(context);
    const idx = notes.findIndex(n => n.id === id);
    if (idx >= 0) {
      notes[idx] = {
        id: notes[idx].id,
        text: trimmed,
        createdAt: notes[idx].createdAt,
        updatedAt: Date.now(),
        reminderIds: notes[idx].reminderIds
      };
      await this.save(context, notes);
    }
    return notes.sort((a, b) => b.updatedAt - a.updatedAt);
  }

  async addReminderId(context: Context, noteId: string, reminderId: number): Promise<Note | null> {
    const notes = await this.load(context);
    const idx = notes.findIndex(n => n.id === noteId);
    if (idx < 0) {
      return null;
    }
    const ids = notes[idx].reminderIds.slice();
    ids.push(reminderId);
    notes[idx] = {
      id: notes[idx].id,
      text: notes[idx].text,
      createdAt: notes[idx].createdAt,
      updatedAt: notes[idx].updatedAt,
      reminderIds: ids
    };
    await this.save(context, notes);
    return notes[idx];
  }

  async clearReminderIds(context: Context, noteId: string): Promise<number[]> {
    const notes = await this.load(context);
    const idx = notes.findIndex(n => n.id === noteId);
    if (idx < 0) {
      return [];
    }
    const cleared = notes[idx].reminderIds.slice();
    notes[idx] = {
      id: notes[idx].id,
      text: notes[idx].text,
      createdAt: notes[idx].createdAt,
      updatedAt: notes[idx].updatedAt,
      reminderIds: []
    };
    await this.save(context, notes);
    return cleared;
  }

  async pin(context: Context, text: string): Promise<void> {
    await PreferencesUtil.getInstance().putValue(context, StorageKeys.PINNED_NOTE_TEXT, text);
  }

  async clearPin(context: Context): Promise<void> {
    await Promise.all([
      PreferencesUtil.getInstance().remove(context, StorageKeys.PINNED_NOTE_TEXT),
      PreferencesUtil.getInstance().remove(context, StorageKeys.PINNED_NOTE_ID)
    ]);
  }

  async getPinnedText(context: Context): Promise<string> {
    const v = await PreferencesUtil.getInstance().getValue(context, StorageKeys.PINNED_NOTE_TEXT, '');
    return typeof v === 'string' ? v : '';
  }
}
