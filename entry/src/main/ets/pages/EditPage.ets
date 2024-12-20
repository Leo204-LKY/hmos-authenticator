import { EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar';
import { LabelledSelect } from '../components/LabelledSelect'
import { LabelledTextInput } from '../components/LabelledTextInput'
import { promptAction } from '@kit.ArkUI';
import { RelationalStore } from '../models/RelationalStore'
import { Preferences } from '../models/Preferences'
import { CancelDialog } from '../components/CancelDialog'
import { ValuesBucket } from '@kit.ArkData';
import { AuthenticatorClass } from '../models/AuthenticatorClass';

const rdbStore = RelationalStore.getInstance();
const preferences = Preferences.getInstance();

const otpOptions: SelectOption[] = [
  { value: 'TOTP' },
  { value: 'HOTP' }
]

const hashOptions: SelectOption[] = [
  { value: 'SHA1' },
  { value: 'SHA256' },
  { value: 'SHA512' }
]

export class EditPageParams {
  private _authenticator: AuthenticatorClass;

  constructor(authenticator: AuthenticatorClass) {
    this._authenticator = authenticator
  }

  get authenticator(): AuthenticatorClass { return this._authenticator; }
}

@Builder
export function editPageBuilder() {
  EditPage()
}

@Entry
@Component
struct EditPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State issuer: string = '';
  @State account: string = '';
  @State secret: string = '';
  @State updateInterval: string = '30';
  @State digits: string = '6';
  @State selectedOTPIndex: number = 0;
  @State selectedOTPValue: string = '';
  @State selectedHashIndex: number = 0;
  @State selectedHashValue: string = '';
  @State advancedSettingsVisible: boolean = false;
  @State itemEdited: boolean = false;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CancelDialog({
      message: $r("app.string.EditPage_confirmCancelMessage"),
      confirm: () => { this.navPathStack.pop() }
    }),
  })

  build() {
    NavDestination() {
      Column() {
        EditableTitleBar({
          title: this.pageTitle,
          onSave: this.saveAuthenticator,
          onCancel: this.cancelOperation
        })

        Scroll() {
          GridRow({ columns: { sm: 4, md: 8, lg: 12 } }) {
            GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { md: 1, lg: 2 } }) {
              Column({ space: 10 }) {
                LabelledTextInput({
                  text: this.issuer,
                  label: $r("app.string.EditPage_issuer"),
                  required: true,
                  onChange: this.onItemEdit
                })

                LabelledTextInput({
                  text: this.account,
                  label: $r("app.string.EditPage_account"),
                  onChange: this.onItemEdit
                })

                LabelledTextInput({
                  text: this.secret,
                  label: $r("app.string.EditPage_secret"),
                  inputType: InputType.Password,
                  required: true,
                  onChange: this.onItemEdit
                })

                Button($r("app.string.EditPage_showAdvancedButton"))
                  .alignSelf(ItemAlign.Center)
                  .margin({ top: 20 })
                  .buttonStyle(ButtonStyleMode.NORMAL)
                  .visibility(this.advancedSettingsVisible ? Visibility.None : Visibility.Visible)
                  .onClick(() => {
                    this.advancedSettingsVisible = true;
                  })

                Grid() {
                  GridItem() {
                    LabelledSelect({
                      label: $r("app.string.EditPage_type"),
                      selectOption: otpOptions,
                      selectedIndex: this.selectedOTPIndex,
                      value: this.selectedOTPValue,
                      selectEnabled: false,
                      onSelect: this.onItemEdit
                    })
                      .width('100%')
                      .onClick(() => {
                        promptAction.showToast({
                          message: $r("app.string.EditPage_notSupportToast"),
                          duration: 2000
                        })
                      })
                  }

                  GridItem() {
                    LabelledSelect({
                      label: $r("app.string.EditPage_hash"),
                      selectOption: hashOptions,
                      selectedIndex: this.selectedHashIndex,
                      value: this.selectedHashValue,
                      onSelect: this.onItemEdit
                    })
                      .width('100%')
                  }

                  GridItem() {
                    LabelledTextInput({
                      text: this.updateInterval,
                      inputType: InputType.Number,
                      label: $r("app.string.EditPage_interval"),
                      required: true,
                      onChange: this.onItemEdit
                    })
                  }

                  GridItem() {
                    LabelledTextInput({
                      text: this.digits,
                      inputType: InputType.Number,
                      label: $r("app.string.EditPage_digits"),
                      required: true,
                      onChange: this.onItemEdit
                    })
                  }
                }
                .columnsTemplate('1fr 1fr')
                .rowsGap(10)
                .columnsGap(10)
                .visibility(this.advancedSettingsVisible ? Visibility.Visible : Visibility.None)
              }
              .height('100%')
              .padding({ left: 15, right: 15, top: 10 })
              .alignItems(HorizontalAlign.Start)
            }
          }
        }
        .edgeEffect(EdgeEffect.Spring)
      }
      .height('100%')
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.background_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onBackPressed(this.onBackPress)
  }

  aboutToAppear(): void {
    let sortPageParams = this.navPathStack.getParamByIndex(0) as EditPageParams | null;

    if (sortPageParams) {
    }
  }

  onBackPress = () => {
    this.cancelOperation();
    return true;  // 不进行自动页面路由
  }

  cancelOperation = () => {
    if ( this.itemEdited ) {
      this.dialogController?.open();
    } else {
      this.navPathStack.pop();
    }
  }

  saveAuthenticator = async () => {
    if (this.issuer.length == 0 || this.secret.length == 0 || this.updateInterval.length == 0 || this.digits.length == 0) {
      promptAction.showToast({
        message: $r('app.string.EditPage_fillAllFieldsToast'),
        duration: 2000
      })
    } else {
      let authenticatorSequence = await preferences.get('authenticatorSequence', []) as number[];
      let values: ValuesBucket = {
        issuer: this.issuer,
        account: this.account,
        secret: this.secret,
        protocol: this.selectedOTPValue,
        algorithm: this.selectedHashValue,
        digits: this.digits,
        update_interval: this.updateInterval
      }

      let rowId = await rdbStore.insert('authenticator', values)

      if (rowId != -1) {
        authenticatorSequence.push(rowId);
        preferences.set('authenticatorSequence', authenticatorSequence);

        this.navPathStack.pop();
      }
    }
  }

  onItemEdit = () => {  // 需使用箭头函数
    this.itemEdited = true;
  }
}