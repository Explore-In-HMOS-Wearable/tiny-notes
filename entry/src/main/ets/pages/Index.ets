import { ArcList, ArcListItem, ArcSwiper, prompt } from '@kit.ArkUI';
import { PreferencesUtil } from '../utils/PreferencesUtils';
import { formBindingData } from '@kit.FormKit';
import { formProvider } from '@kit.FormKit';


@Entry
@Component
struct TinyNotesPage {
  @State notes: Array<string> = [];
  @State noteInput: string = '';
  @State selectedNote: number = -1;
  private context: Context = AppStorage.get('context') as Context

  build() {
    ArcSwiper() {
      Scroll() {
        Column() {
          Text('Tiny Notes')
            .fontSize(22)
            .fontWeight(600)
            .padding(12)
            .fontColor(Color.Pink)

          TextInput({
            placeholder: 'Keep in mind…'
          })
            .onChange(v => {
              this.noteInput = v
            })
            .margin(8)
            .width('85%')
            .height(38)
            .backgroundColor(Color.Gray)
            .fontSize(12)
            .placeholderFont({ size: 12 })
            .maxLength(20)

          Button('Add')
            .onClick(() => {
              this.showNote('To see notes please swipe!')
              this.addNote()
            })
            .margin(8)
            .fontSize(12)
            .height(30)
            .backgroundColor(Color.Green)
        }
        .padding(12)
      }.width('100%')
      .height('100%')


      ArcList({ initialIndex: 1 }) {
        ArcListItem() {
          Image($r('app.media.sticky_note')).width(40)
        }

        ArcListItem() {
          Column() {
            Text('All Notes')
              .fontSize(16)
              .margin({ top: 8 })
              .fontColor(Color.Pink)
            Text('Pin this note to your widget!')
              .fontSize(10)
              .margin({ top: 2, bottom: 8 })
              .fontColor(Color.Pink)
          }

        }

        ForEach(this.notes, (item: string, index: number) => {
          ArcListItem() {
            Row() {
              Text(item)
                .fontSize(12)
                .fontWeight(400)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ left: 10, right: 10 })

              Button('Show')
                .onClick(() => {
                  PreferencesUtil.getInstance().getValue(this.context, 'formId', 'default').then((formId) => {
                    const data: formBindingData.FormBindingData = formBindingData.createFormBindingData({
                      text: item
                    })
                    formProvider.updateForm(formId as string, data);
                  })

                  this.showNote(item)
                  this.selectedNote = index
                })
                .margin(8)
                .fontSize(10)
                .height(25)
                .backgroundColor(Color.Pink)
            }
            .padding({
              left: 6,
              right: 6
            })
            .margin({ bottom: 2 })
            .width('90%')
            .borderWidth(1)
            .borderRadius(50)
            .borderColor(this.selectedNote === index ? Color.Green : Color.Gray)
            .justifyContent(FlexAlign.SpaceBetween)
          }
        })
      }

    }
  }

  addNote() {
    if (!this.noteInput.trim()) {
      return;
    }
    this.notes.push(this.noteInput);
    this.noteInput = '';
  }

  showNote(text: string) {
    prompt.showToast({
      message: text,
      duration: 2000
    });
  }
}
