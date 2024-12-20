import promptAction from '@ohos.promptAction'
import relationalStore from '@ohos.data.relationalStore'
import { RelationalStore } from '../models/RelationalStore'
import { Preferences } from '../models/Preferences'
import { AuthenticatorClass } from '../models/AuthenticatorClass'
import { AuthenticatorItem } from '../components/AuthenticatorItem'
import { scanBarcode, scanCore } from '@kit.ScanKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { SortPageParams } from './SortPage'
import { addAuthenticatorFromUrl } from '../utils/AddAuthenticatorItemFromUrl'
import { getAuthenticators } from '../utils/AuthenticatorData'
import { window } from '@kit.ArkUI'
import { preferences as prefClass } from '@kit.ArkData'
import { EmptyIndexHint } from '../components/EmptyIndexHint'

const rdbStore = RelationalStore.getInstance();
const preferences = Preferences.getInstance();

@Entry
@Component
struct Index {
  @State authenticators: AuthenticatorClass[] = [];
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  private windowClass = AppStorage.get('windowClass') as window.Window;

  private menuItems: Array<NavigationMenuItem> = [
    {
      value: getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_add')),
      icon: 'resources/base/media/ic_public_add.svg',
      action: () => {
        this.getUIContext().showAlertDialog({
          title: $r('app.string.addDialog_title'),
          message: $r('app.string.addDialog_description'),
          alignment: DialogAlignment.Center,
          buttons: [
            {
              value: $r('app.string.addDialog_scanToAdd'),
              action: () => {
                let options: scanBarcode.ScanOptions = {
                  scanTypes: [scanCore.ScanType.QR_CODE],
                  enableMultiMode: true,
                  enableAlbum: true
                };

                try {
                  scanBarcode.startScanForResult(getContext(this), options)
                    .then((result: scanBarcode.ScanResult) => {
                      let scanValue = result.originalValue
                      console.log(`Scan result: ${scanValue}`)
                      if (scanValue.toLowerCase().startsWith('otpauth://totp/')) {
                        addAuthenticatorFromUrl(scanValue)
                          .then(() => {
                            promptAction.showToast({
                              message: $r('app.string.scanAdd_successToast'),
                              duration: 2000
                            })
                            this.updateAuthenticators();
                          })
                      } else if (scanValue.toLowerCase().startsWith('otpauth://hotp/')) { // TOTP 类型暂不支持
                        promptAction.showToast({
                          message: $r('app.string.scanAdd_notSupportToast'),
                          duration: 3000
                        })
                      } else {  // 非有效的 OTP 二维码
                        promptAction.showToast({
                          message: $r('app.string.scanAdd_invalidCodeToast'),
                          duration: 2000
                        })
                      }
                    })
                    .catch((error: BusinessError) => {
                      console.log(`Failed to get ScanResult by promise with options. Code:${error.code}, message: ${error.message}`)
                    })
                } catch (error) {
                  console.error(`Failed to start the scanning service. Code:${error.code}, message: ${error.message}`)
                }
              }
            },
            {
              value: $r('app.string.addDialog_manualAdd'),
              action: () => { this.navPathStack.pushPath({ name: 'EditPage' })}
            }
          ]
        })
      }
    },
    // {
    //   value: getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_search')),
    //   icon: 'resources/base/media/ic_public_search.svg',
    //   action: () => {}
    // },
    {
      value: 'Sort', // getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_more')),
      icon: 'resources/base/media/ic_public_view_list.svg',
      action: () => {
        let sortPageParams = new SortPageParams(this.authenticators)
        this.navPathStack.pushPath({ name: 'SortPage', param: sortPageParams })
      }
    },
    {
      value: getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_settings')),
      icon: 'resources/base/media/gearshape.svg',
      action: () => { this.navPathStack.pushPath({ name: 'SettingsPage' }) }
    }
  ]

  build() {
    Navigation(this.navPathStack) {
      Scroll() {
        if (this.authenticators.length == 0) {
          EmptyIndexHint()
        } else {
          GridRow({ columns: { sm: 4, md: 8, lg: 12 } }) {
            GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { md: 1, lg: 2 } }) {
              List({ space: 10 }) {
                ForEach(this.authenticators, (item: AuthenticatorClass) => {
                  AuthenticatorItem({ authenticator: item })
                })
              }
              .width('100%')
              .height('100%')
              .listDirection(Axis.Vertical)
              .alignListItem(ListItemAlign.Center)
              .margin({ top: 24 })
            }
          }
        }
      }
      .height('100%')
      .width('100%')
      .align(this.authenticators.length == 0 ? Alignment.Center : Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
    }
    .height('100%')
    .width('100%')
    .title($r('app.string.mainPage_title'))
    .menus(this.menuItems)
    .backgroundColor($r('app.color.background_primary'))
    .mode(NavigationMode.Stack)
  }

  aboutToAppear(): void {
    this.updateAuthenticators();
    setInterval(() => { this.emitTimestamp(); }, 1000);
    getContext(this).eventHub.on('onDeleteAuthenticator', (id: number) => { this.deleteAuthenticator(id); });
    getContext(this).eventHub.on('onUpdateAuthenticators', () => { this.updateAuthenticators(); })
    preferences.get('privacyMode', true)
      .then((value: prefClass.ValueType) => {
        let privacyMode = value as boolean;
        this.windowClass.setWindowPrivacyMode(privacyMode);
      })
  }

  updateAuthenticators: Function = () => {
    getAuthenticators()
      .then((authenticators: AuthenticatorClass[]) => {
        this.authenticators = authenticators;
      })
  };

  private emitTimestamp() {
    const timestamp = Math.floor(Date.now() / 1000);
    getContext(this).eventHub.emit('onEmitTimestamp', timestamp);
  }

  private async deleteAuthenticator(idToRemove: number) {
    let predicates = new relationalStore.RdbPredicates('authenticator');
    predicates.equalTo('id', idToRemove);
    rdbStore.delete(predicates);
    let authenticatorSequence = await preferences.get('authenticatorSequence', []) as number[];
    await preferences.set('authenticatorSequence', authenticatorSequence.filter(id => id != idToRemove));
    this.updateAuthenticators();
  }
}