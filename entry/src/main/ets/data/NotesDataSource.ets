import { Note } from '../model/Note';

export class NotesDataSource implements IDataSource {
  private notes: Note[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.notes.length;
  }

  getData(index: number): Note {
    return this.notes[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx >= 0) {
      this.listeners.splice(idx, 1);
    }
  }

  getAll(): Note[] {
    return this.notes.slice();
  }

  reload(notes: Note[]): void {
    this.notes = notes.slice();
    this.listeners.forEach(l => l.onDataReloaded());
  }

  addAt(index: number, note: Note): void {
    this.notes.splice(index, 0, note);
    this.listeners.forEach(l => l.onDataAdd(index));
  }

  removeById(id: string): number {
    const idx = this.notes.findIndex(n => n.id === id);
    if (idx < 0) {
      return -1;
    }
    this.notes.splice(idx, 1);
    this.listeners.forEach(l => l.onDataDelete(idx));
    return idx;
  }

  updateById(id: string, next: Note): number {
    const idx = this.notes.findIndex(n => n.id === id);
    if (idx < 0) {
      return -1;
    }
    this.notes[idx] = next;
    this.listeners.forEach(l => l.onDataChange(idx));
    return idx;
  }
}
