import { EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar';
import router from '@ohos.router';
import { LabelledTextInput, LabelledSelect } from 'uicomponents'
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ManualAddPage {
  @State issuer: string = '';
  @State account: string = '';
  @State secret: string = '';
  @State updateInterval: string = '30';
  @State digits: string = '6';
  @State selectedOTPType: number = 0;
  @State selectedHashType: number = 0;
  @State advancedSettingsVisible: boolean = false;
  @State itemEdited: boolean = false;

  build() {
    Column() {
      EditableTitleBar({
        title: $r('app.string.manualAddPage_title'),
        onSave: () => {},
        onCancel: this.cancelOperation
      })

      Scroll() {
        Column({ space: 10 }) {
          LabelledTextInput({
            text: this.issuer,
            label: $r('app.string.manualAddPage_issuer'),
            required: true,
            onChange: this.onItemEdit
          })

          LabelledTextInput({
            text: this.account,
            label: $r('app.string.manualAddPage_account'),
            onChange: this.onItemEdit
          })

          LabelledTextInput({
            text: this.secret,
            label: $r('app.string.manualAddPage_secret'),
            inputType: InputType.Password,
            required: true,
            onChange: this.onItemEdit
          })

          Button($r('app.string.manualAddPage_showAdvancedButton'))
            .alignSelf(ItemAlign.Center)
            .margin({ top: 20 })
            .buttonStyle(ButtonStyleMode.NORMAL)
            .visibility(this.advancedSettingsVisible? Visibility.None : Visibility.Visible)
            .onClick(() => { this.advancedSettingsVisible = true; })

          Grid() {
            GridItem() {
              LabelledSelect({
                label: $r('app.string.manualAddPage_type'),
                selectOption: [
                  { value: 'TOTP' },
                  { value: 'HOTP' }
                ],
                selectedIndex: this.selectedOTPType,
                selectEnabled: false,
                onSelect: this.onItemEdit
              })
                .width('100%')
                .onClick(() => {
                  promptAction.showToast({
                    message: $r('app.string.manualAddPage_notSupportToast'),
                    duration: 2000
                  })
                })
            }

            GridItem() {
              LabelledSelect({
                label: $r('app.string.manualAddPage_hash'),
                selectOption: [
                  { value: 'SHA1' },
                  { value: 'SHA256' },
                  { value: 'SHA512' }
                ],
                selectedIndex: this.selectedHashType,
                onSelect: this.onItemEdit
              })
                .width('100%')
            }

            GridItem() {
              LabelledTextInput({
                text: this.updateInterval,
                inputType: InputType.Number,
                label: $r('app.string.manualAddPage_interval'),
                required: true,
                onChange: this.onItemEdit
              })
            }

            GridItem() {
              LabelledTextInput({
                text: this.digits,
                inputType: InputType.Number,
                label: $r('app.string.manualAddPage_digits'),
                required: true,
                onChange: this.onItemEdit
              })
            }
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(10)
          .columnsGap(10)
          .visibility(this.advancedSettingsVisible? Visibility.Visible : Visibility.None)
        }
        .height('100%')
        .padding({ left: 15, right: 15, top: 10 })
        .alignItems(HorizontalAlign.Start)
      }
      .edgeEffect(EdgeEffect.Spring)
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.gray_01'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
  }

  onBackPress(): boolean | void {
    this.cancelOperation();
    return true;  // 不进行自动页面路由
  }

  cancelOperation = () => {
    if ( this.itemEdited ) {
      this.getUIContext().showAlertDialog({
        title: $r('app.string.manualAddPage_cancelDialog_title'),
        message: $r('app.string.manualAddPage_cancelDialog_description'),
        alignment: DialogAlignment.Center,
        buttons: [
          {
            value: $r('app.string.manualAddPage_cancelDialog_no'),
            action: () => {}
          },
          {
            value: $r('app.string.manualAddPage_cancelDialog_yes'),
            action: () => { router.back() }
          }
        ],
        cancel: () => {}
      })
    } else {
      router.back();
    }
  }

  onItemEdit = () => {  // 需使用箭头函数
    this.itemEdited = true;
  }
}