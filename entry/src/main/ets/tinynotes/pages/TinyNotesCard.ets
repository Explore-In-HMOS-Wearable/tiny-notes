let storage = new LocalStorage();

@Entry(storage)
@Component
struct TinyNotesCard {
  @LocalStorageProp('text') text: string = '';

  build() {
    FormLink({
      action: 'router',
      abilityName: 'EntryAbility'
    }) {
      Column() {
        Row() {
          Image($r('app.media.sticky_note'))
            .width(16)
            .height(16)
            .margin({ right: 6 })
          Text($r('app.string.card_title'))
            .fontSize(11)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        if (this.text && this.text.length > 0) {
          Text(this.text)
            .fontSize(this.text.length > 24 ? 13 : 16)
            .fontColor($r('sys.color.font'))
            .fontWeight(FontWeight.Medium)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ top: 10 })
        } else {
          Text($r('app.string.widget_no_note'))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ top: 10 })
        }
      }
      .width('100%')
      .height('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.comp_background_primary'))
    }
  }
}
