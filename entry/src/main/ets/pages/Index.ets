import relationalStore from '@ohos.data.relationalStore'
import { RelationalStore } from '../models/RelationalStore'
import { Preferences } from '../models/Preferences'
import { AuthenticatorClass } from '../models/AuthenticatorClass'
import { AuthenticatorItem } from '../components/AuthenticatorItem'
import { getAuthenticators } from '../utils/AuthenticatorData'
import { window } from '@kit.ArkUI'
import { preferences as prefClass } from '@kit.ArkData'
import { EmptyIndexHint } from '../components/EmptyIndexHint'
import { buildIndexNavMenu } from '../components/IndexNavMenu'
import { EventConstants } from '../models/EventConstants'
import { PreferenceConstants } from '../models/PreferenceConstants'

const rdbStore = RelationalStore.getInstance();
const preferences = Preferences.getInstance();

@Entry
@Component
struct Index {
  @Provide('authenticators') authenticators: AuthenticatorClass[] = [];
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  private windowClass = AppStorage.get('windowClass') as window.Window;

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
    .menus(buildIndexNavMenu())
    .backgroundColor($r('app.color.background_primary'))
    .mode(NavigationMode.Stack)
  }

  aboutToAppear(): void {
    this.updateAuthenticators();
    setInterval(() => { this.emitTimestamp(); }, 1000);
    getContext(this).eventHub.on(EventConstants.ON_DELETE_AUTHENTICATOR, (id: number) => { this.deleteAuthenticator(id); });
    getContext(this).eventHub.on(EventConstants.ON_UPDATE_AUTHENTICATORS, () => { this.updateAuthenticators(); })
    preferences.get(PreferenceConstants.PRIVACY_MODE, true)
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
    getContext(this).eventHub.emit(EventConstants.ON_EMIT_TIMESTAMP, timestamp);
  }

  private async deleteAuthenticator(idToRemove: number) {
    let predicates = new relationalStore.RdbPredicates('authenticator');
    predicates.equalTo('id', idToRemove);
    rdbStore.delete(predicates);
    let authenticatorSequence = await preferences.get(PreferenceConstants.AUTHENTICATOR_SEQUENCE, []) as number[];
    await preferences.set(PreferenceConstants.AUTHENTICATOR_SEQUENCE, authenticatorSequence.filter(id => id != idToRemove));
    this.updateAuthenticators();
  }
}