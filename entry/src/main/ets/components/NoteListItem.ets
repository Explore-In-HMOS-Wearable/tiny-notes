import { ArcListItem } from '@kit.ArkUI';
import { Limits } from '../constants/StorageKeys';
import { Note } from '../model/Note';

const EMPTY_NOTE: Note = {
  id: '',
  text: '',
  createdAt: 0,
  updatedAt: 0,
  reminderIds: []
};

@Component
export struct NoteListItem {
  @Prop note: Note = EMPTY_NOTE;
  @Prop isSelected: boolean = false;
  onOpenNote: (note: Note) => void = () => {};
  onPinNote: (note: Note) => void = () => {};
  onRequestDelete: (note: Note) => void = () => {};
  private readonly handleOpen = (): void => this.onOpenNote(this.note);
  private readonly handlePin = (): void => this.onPinNote(this.note);
  private readonly handleDeleteGesture = (evt: GestureEvent): void => {
    if (evt.offsetX < -Limits.SWIPE_DELETE_THRESHOLD) {
      this.onRequestDelete(this.note);
    }
  };

  build() {
    ArcListItem() {
      Row() {
        Text(this.note.text)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 10, right: 10 })
          .layoutWeight(1)
          .onClick(this.handleOpen)

        Row() {
          Image(this.isSelected
            ? $r('app.media.ic_pin_filled')
            : $r('app.media.ic_pin'))
            .width(14)
            .height(14)
        }
          .onClick(this.handlePin)
          .accessibilityText($r('app.string.a11y_pin'))
          .margin(8)
          .width(28)
          .height(28)
          .backgroundColor($r('app.color.brand_primary'))
          .justifyContent(FlexAlign.Center)
      }
      .padding({ left: 6, right: 6 })
      .margin({ bottom: 2 })
      .width('90%')
      .borderWidth(1)
      .borderRadius(50)
      .borderColor(this.isSelected
        ? $r('app.color.border_selected')
        : $r('app.color.border_default'))
      .justifyContent(FlexAlign.SpaceBetween)
      .accessibilityDescription($r('app.string.a11y_swipe_delete'))
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal, distance: 8 })
          .onActionEnd(this.handleDeleteGesture)
      )
    }
  }
}
