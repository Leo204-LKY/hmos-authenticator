import { EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar';
import { LabelledSelect } from '../components/LabelledSelect';
import { LabelledTextInput } from '../components/LabelledTextInput';
import { promptAction } from '@kit.ArkUI';
import { RelationalStore } from '../models/RelationalStore';
import { Preferences } from '../models/Preferences';
import { CancelDialog } from '../components/CancelDialog';
import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { AuthenticatorClass } from '../models/AuthenticatorClass';

const rdbStore = RelationalStore.getInstance();
const preferences = Preferences.getInstance();

const otpTypeOptions: SelectOption[] = [
  { value: 'TOTP' },
  { value: 'HOTP' }
]

const algorithmOptions: SelectOption[] = [
  { value: 'SHA1' },
  { value: 'SHA256' },
  { value: 'SHA512' }
]

export class EditPageParams {
  private _authenticator: AuthenticatorClass;

  constructor(authenticator: AuthenticatorClass) {
    this._authenticator = authenticator;
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
  @State selectedOtpTypeIndex: number = 0;
  @State selectedOtpTypeValue: string = '';
  @State selectedAlgorithmIndex: number = 0;
  @State selectedAlgorithmValue: string = '';
  @State advancedSettingsVisible: boolean = false;
  @State itemEdited: boolean = false;
  @State pageTitle: ResourceStr = $r("app.string.EditPage_addTitle")
  @State editMode: boolean = false;   // false：添加验证器，true：修改验证器
  private editItemId: number = -1;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CancelDialog({
      message: $r("app.string.EditPage_confirmCancelMessage"),
      confirm: () => { this.navPathStack.pop() }
    })
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
                  onChange: this.onItemEdit,
                  inputEnabled: this.editMode ? false : true
                })
                  .onClick(this.editMode ? () => {
                    promptAction.showToast({
                      message: $r("app.string.EditPage_secretNotEditableToast"),
                      duration: 2000
                    })
                  } : null)

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
                      selectOption: otpTypeOptions,
                      selectedIndex: this.selectedOtpTypeIndex,
                      value: this.selectedOtpTypeValue,
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
                      label: $r("app.string.EditPage_algorithm"),
                      selectOption: algorithmOptions,
                      selectedIndex: this.selectedAlgorithmIndex,
                      value: this.selectedAlgorithmValue,
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

    // 传入了 authenticator 参数 - 编辑验证器
    if (sortPageParams) {
      this.editMode = true;
      this.pageTitle = $r('app.string.EditPage_editTitle');

      let authenticator = sortPageParams.authenticator;
      this.editItemId = authenticator.id;
      this.issuer = authenticator.issuer;
      this.account = authenticator.account ? authenticator.account : '';
      this.secret = 'SOMESECRETOFYOURAUTH'    // Secret 不支持编辑
      this.selectedOtpTypeIndex = otpTypeOptions.findIndex(option => (option.value == authenticator.otpType));
      this.selectedAlgorithmIndex = algorithmOptions.findIndex(option => (option.value == authenticator.algorithm));
      this.updateInterval = authenticator.updateInterval.toString();
      this.digits = authenticator.digits.toString();
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
    console.log('Saving authenticator')
    let success = false;
    if (this.issuer.length == 0 || this.secret.length == 0 || this.updateInterval.length == 0 || this.digits.length == 0) {
      promptAction.showToast({
        message: $r('app.string.EditPage_fillAllFieldsToast'),
        duration: 2000
      })
    } else if (this.editMode) {
      success = await this.saveEditedAuthenticator();
    } else {
      success = await this.saveNewAuthenticator();
    }

    if (success) {
      getContext(this).eventHub.emit('onUpdateAuthenticators');
      this.navPathStack.pop();
    }
  }

  private async saveNewAuthenticator(): Promise<boolean> {
    let authenticatorSequence = await preferences.get('authenticatorSequence', []) as number[];
    let values: ValuesBucket = {
      issuer: this.issuer,
      account: this.account,
      secret: this.secret,
      otp_type: this.selectedOtpTypeValue,
      algorithm: this.selectedAlgorithmValue,
      digits: this.digits,
      update_interval: this.updateInterval
    }

    let rowId = await rdbStore.insert('authenticator', values)

    if (rowId != -1) {
      authenticatorSequence.push(rowId);
      preferences.set('authenticatorSequence', authenticatorSequence);
      return true;
    }
    return false;
  }

  async saveEditedAuthenticator(): Promise<boolean> {
    console.log('Saving edited authenticator')
    let values: ValuesBucket = {
      issuer: this.issuer,
      account: this.account,
      otp_type: this.selectedOtpTypeValue,
      algorithm: this.selectedAlgorithmValue,
      digits: this.digits,
      update_interval: this.updateInterval
    }

    let predicates = new relationalStore.RdbPredicates('authenticator')
    predicates.equalTo('id', this.editItemId);

    await rdbStore.update(values, predicates);
    return true;
  }

  onItemEdit = () => {  // 需使用箭头函数
    this.itemEdited = true;
  }
}