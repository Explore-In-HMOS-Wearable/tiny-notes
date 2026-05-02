export class StorageKeys {
  static readonly NOTES: string = 'notes';
  static readonly FORM_ID: string = 'formId';
  static readonly FORM_IDS: string = 'formIds';
  static readonly PINNED_NOTE_TEXT: string = 'pinnedNoteText';
  static readonly PINNED_NOTE_ID: string = 'pinnedNoteId';
}

export class Limits {
  static readonly NOTE_MAX_LENGTH: number = 140;
  static readonly NOTES_MAX_COUNT: number = 500;
  static readonly SWIPE_DELETE_THRESHOLD: number = 80;
  static readonly HAPTIC_MS: number = 20;
}
