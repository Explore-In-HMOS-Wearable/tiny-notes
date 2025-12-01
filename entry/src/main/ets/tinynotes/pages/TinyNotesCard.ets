@Entry
@Component
struct TinyNotesCard {
  /*
  * The display priority value is 1.
  */
  readonly displayPriorityOne = 1;
  /*
   * The display priority value is 2.
   */
  readonly displayPriorityTwo = 2;
  /*
   * The flex grow value is 1.
   */
  readonly flexGrowValue = 1;
  /*
   * The width or height full percentage setting.
   */
  readonly fullPercent = '100%';
  /*
   * The height of image.
   */
  readonly imageHeight = '54%';
  /*
   * The action type.
   */
  readonly actionType = 'router';
  /*
   * The ability name.
  */
  readonly abilityName = 'EntryAbility';
  /*
   * The message.
   */
  readonly message = 'add detail';
  /*
   * The layoutWeightValue.
   */
  readonly layoutWeightValue = 1;
  /*
   * The maxLinesValue.
   */
  readonly maxLinesValue = 1;

  @LocalStorageProp('text') text : string = 'Hello World';

  build() {
    FormLink({
      action: this.actionType,
      abilityName: this.abilityName,
      params: {
        message: this.message
      }
    }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.ic_widget'))
            .width(this.fullPercent)
            .height(this.fullPercent)

          Column() {
            Text($r('app.string.card_title'))
              .fontSize($r('app.float.card_title_font_size'))
              .width(this.fullPercent)
              .fontColor($r('sys.color.font'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
          }
          .padding($r('app.float.maximum_padding'))
          .alignItems(HorizontalAlign.Start)
        }
        .width(this.fullPercent)
        .height(this.fullPercent)
        .displayPriority(this.displayPriorityOne)
        .flexGrow(this.flexGrowValue)

        Flex({ direction: FlexDirection.Column }) {
          Flex({ direction: FlexDirection.Row }) {
            Column() {
              Image($r('app.media.sticky_note'))
                .width(this.fullPercent)
                .height(this.imageHeight)
                .borderRadius($r('app.float.image_border_radius'))
                .margin({ bottom: $r('app.float.image_margin_bottom') })
                .flexGrow(this.flexGrowValue)
                .objectFit(ImageFit.Contain)

              Column() {
                Text('Tiny Notes')
                  .fontSize($r('app.float.item_font_size'))
                  .width(this.fullPercent)
                  .fontColor($r('sys.color.font'))
                  .fontWeight(FontWeight.Medium)
                  .maxLines(this.maxLinesValue)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Start)
                Text(this.text)
                  .fontSize($r('app.float.card_title_font_size'))
                  .width(this.fullPercent)
                  .fontColor($r('sys.color.font'))
                  .fontWeight(FontWeight.Regular)
                  .margin({ top: $r('app.float.item_margin_top') })
                  .maxLines(this.maxLinesValue)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Start)
              }
              .justifyContent(FlexAlign.Center)
              .layoutWeight(this.layoutWeightValue)
              .flexGrow(this.flexGrowValue)
            }
            .width($r('app.float.info_column_width'))
            .height(this.fullPercent)
            .flexGrow(this.flexGrowValue)
          }
          .backgroundColor($r('sys.color.comp_background_primary'))
          .displayPriority(this.displayPriorityTwo)
          .flexGrow(this.flexGrowValue)
          .height($r('app.float.info_column_height'))
          .padding($r('app.float.info_column_padding'))
        }
      }
    }
  }
}