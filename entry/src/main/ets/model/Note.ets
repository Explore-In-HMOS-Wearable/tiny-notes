import { secureRandomInt } from '../utils/SecureRandom';

export interface Note {
  id: string;
  text: string;
  createdAt: number;
  updatedAt: number;
  reminderIds: number[];
}

interface CreateNoteOptions {
  id?: string;
  createdAt?: number;
  updatedAt?: number;
  reminderIds?: number[];
}

interface RawNoteData {
  id?: Object;
  text?: Object;
  createdAt?: Object;
  updatedAt?: Object;
  reminderIds?: Object;
}

export function createNote(text: string, options?: CreateNoteOptions): Note {
  const now = options?.updatedAt ?? options?.createdAt ?? Date.now();
  return {
    id: options?.id && options.id.length > 0
      ? options.id
      : `${now}_${secureRandomInt(1000000)}`,
    text,
    createdAt: options?.createdAt ?? now,
    updatedAt: options?.updatedAt ?? now,
    reminderIds: options?.reminderIds ? options.reminderIds.slice() : []
  };
}

export function normalizeNote(raw: Note | string | Object | null | undefined, fallbackTime: number = Date.now()):
  Note | null {
  if (typeof raw === 'string') {
    const text = raw.trim();
    if (!text) {
      return null;
    }
    return createNote(text, { createdAt: fallbackTime, updatedAt: fallbackTime });
  }

  if (!raw || typeof raw !== 'object') {
    return null;
  }

  const data = raw as RawNoteData;
  const textValue = data.text;
  const text = typeof textValue === 'string' ? textValue.trim() : '';
  if (!text) {
    return null;
  }

  const createdAtValue = data.createdAt;
  const updatedAtValue = data.updatedAt;
  const createdAt = typeof createdAtValue === 'number' ? createdAtValue : fallbackTime;
  const updatedAt = typeof updatedAtValue === 'number' ? updatedAtValue : createdAt;
  const reminderIdsValue = data.reminderIds;
  const reminderIds = Array.isArray(reminderIdsValue)
    ? reminderIdsValue.filter((item: Object) => typeof item === 'number') as number[]
    : [];
  const idValue = data.id;

  return createNote(text, {
    id: typeof idValue === 'string' ? idValue : '',
    createdAt,
    updatedAt,
    reminderIds
  });
}

export function isNormalizedNote(raw: Note | string | Object | null | undefined): boolean {
  if (!raw || typeof raw !== 'object') {
    return false;
  }
  const data = raw as RawNoteData;
  return typeof data.id === 'string' &&
    typeof data.text === 'string' &&
    typeof data.createdAt === 'number' &&
    typeof data.updatedAt === 'number' &&
    Array.isArray(data.reminderIds) &&
    data.reminderIds.every((item: Object) => typeof item === 'number');
}
