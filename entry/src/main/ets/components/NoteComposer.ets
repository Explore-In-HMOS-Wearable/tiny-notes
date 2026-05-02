import { Limits } from '../constants/StorageKeys';

@Component
export struct NoteComposer {
  @Prop noteInput: string = '';
  onInputChange: (value: string) => void = () => {};
  onSubmit: () => void = () => {};
  private readonly handleInputChange = (value: string): void => this.onInputChange(value);
  private readonly handleSubmit = (): void => this.onSubmit();

  build() {
    Scroll() {
      Column() {
        Text($r('app.string.app_title'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .padding({ top: 14, bottom: 10 })
          .fontColor($r('app.color.brand_primary'))

        Text($r('app.string.note_input_label'))
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.on_surface'))
          .width('88%')
          .textAlign(TextAlign.Start)
          .margin({ left: 8, right: 8, bottom: 6 })

        Row() {
          TextInput({ text: this.noteInput, placeholder: $r('app.string.note_input_placeholder') })
            .onChange(this.handleInputChange)
            .onSubmit(this.handleSubmit)
            .enterKeyType(EnterKeyType.Done)
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.field_surface'))
            .borderWidth(2)
            .borderColor($r('app.color.field_border'))
            .borderRadius(22)
            .padding({ left: 14, right: 14 })
            .fontColor($r('app.color.on_surface'))
            .fontSize(14)
            .placeholderFont({ size: 13 })
            .maxLength(Limits.NOTE_MAX_LENGTH)
        }
        .margin({ top: 6, left: 8, right: 8, bottom: 4 })
        .width('88%')

        Text(`${this.noteInput.length}/${Limits.NOTE_MAX_LENGTH}`)
          .fontSize(9)
          .fontColor($r('app.color.on_surface_muted'))
          .margin({ bottom: 10 })

        Row() {
          Text($r('app.string.action_add'))
            .fontSize(12)
            .fontColor($r('app.color.on_primary'))
        }
          .onClick(this.handleSubmit)
          .accessibilityText($r('app.string.a11y_add'))
          .margin({ bottom: 18 })
          .height(34)
          .width(96)
          .borderRadius(18)
          .backgroundColor($r('app.color.brand_accent'))
          .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ top: 10, bottom: 18 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
