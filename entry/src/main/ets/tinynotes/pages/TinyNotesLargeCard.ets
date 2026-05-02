let largeCardStorage = new LocalStorage();

@Entry(largeCardStorage)
@Component
struct TinyNotesLargeCard {
  @LocalStorageProp('text') text: string = '';

  build() {
    FormLink({
      action: 'router',
      abilityName: 'EntryAbility'
    }) {
      Column() {
        if (this.text && this.text.length > 0) {
          Column() {
            Row() {
              Image($r('app.media.sticky_note'))
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text($r('app.string.card_title'))
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            Text(this.text)
              .fontSize(this.text.length > 48 ? 20 : 25)
              .fontColor($r('sys.color.font'))
              .fontWeight(FontWeight.Medium)
              .maxLines(7)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ top: 18 })
          }
          .width('100%')
          .height('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        } else {
          Column() {
            Text('+')
              .fontSize(54)
              .fontColor($r('sys.color.font'))
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(32)
    }
  }
}
