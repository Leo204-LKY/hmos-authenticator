import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import relationalStore from '@ohos.data.relationalStore'
import { RelationalStore } from '../models/RelationalStore'
import { Preferences } from '../models/Preferences'
import { AuthenticatorClass, OtpTypes, OtpAlgorithms, AuthenticatorClassOptions } from '../models/AuthenticatorClass'
import { AuthenticatorItem } from '../components/AuthenticatorItem'

const rdbStore = RelationalStore.getInstance();
const preferences = Preferences.getInstance();

async function getAuthenticators(): Promise<AuthenticatorClass[]> {
  let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('authenticator');
  let queryResult = await rdbStore.getAll(predicates);
  let authenticators: AuthenticatorClass[] = [];
  let authenticatorSequence = await preferences.get('authenticatorSequence', []) as number[];

  for (let i = 0; i < authenticatorSequence.length; i++) {
    for (let j = 0; j < queryResult.length; j++) {
      if (authenticatorSequence[i] == queryResult[j].id) {
        let options: AuthenticatorClassOptions = {
          id: queryResult[j].id as number,
          issuer: queryResult[j].issuer as string,
          account: queryResult[j].account as string,
          secret: queryResult[j].secret as string,
          protocol: queryResult[j].protocol as OtpTypes,
          algorithm: queryResult[j].algorithm as OtpAlgorithms,
          digits: queryResult[j].digits as number,
          updateInterval: queryResult[j].update_interval as number
        }

        authenticators.push(new AuthenticatorClass(options));
        break;
      }
    }
  }

  return authenticators;
}

@Entry
@Component
struct Index {
  @State authenticators: AuthenticatorClass[] = [];

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
                promptAction.showToast({
                  message: 'Add by Scan',
                  duration: 2000
                })
              }
            },
            {
              value: $r('app.string.addDialog_manualAdd'),
              action: () => {
                router.pushUrl({ url: 'pages/ManualAddPage' })
              }
            }
          ]
        })
      }
    },
    {
      value: getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_search')),
      icon: 'resources/base/media/ic_public_search.svg',
      action: () => {}
    },
    {
      value: getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_more')),
      icon: 'resources/base/media/ic_public_more.svg',
      action: () => {}
    }
  ]

  build() {
    Navigation() {
      Scroll() {
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
      .height('100%')
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
    }
    .height('100%')
    .width('100%')
    .title($r('app.string.mainPage_title'))
    .menus(this.menuItems)
    .backgroundColor($r('sys.color.gray_01'))
    .mode(NavigationMode.Stack)
  }

  aboutToAppear(): void {
    setInterval(() => { this.emitTimestamp(); }, 1000);
    getContext(this).eventHub.on('onDeleteAuthenticator', (id: number) => { this.deleteAuthenticator(id); })
  }

  onPageShow(): void {
    getAuthenticators()
      .then((authenticators) => {
        this.authenticators = authenticators;
      });
  }

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
    this.authenticators = await getAuthenticators();
  }
}