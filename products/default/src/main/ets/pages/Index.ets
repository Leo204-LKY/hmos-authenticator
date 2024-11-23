import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import relationalStore from '@ohos.data.relationalStore'
import { RelationalStore, Preferences } from 'globalvariable'
import { AuthenticatorClass, OtpTypes, OtpAlgorithms, AuthenticatorClassOptions } from 'auth'

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

@Component
struct AuthenticatorItem {
  @Require @Prop authenticator: AuthenticatorClass
  @Prop issuer: string;
  @Prop account: string | null;
  @Prop code: string = '';
  @Prop updateInterval: number;
  @Prop timeLeft: number;

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.issuer)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
          Text(this.account)
            .fontSize(15)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.code)
          .fontWeight(600)
          .fontSize(32)
      }

      Blank()
        .height(4)

      Progress({ value: 0, total: this.updateInterval, type: ProgressType.Linear })
        .height(2)
        .value(this.timeLeft)
    }
    .backgroundColor('white')
    .borderRadius(16)
    .width('95%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
  }

  aboutToAppear() {
    this.issuer = this.authenticator.issuer;
    this.account = this.authenticator.account;
    this.updateInterval = this.authenticator.updateInterval;
    this.authenticator.getCode()
      .then((code: string) => {
        this.code = code;
      })
    this.updateTimeLeft(Math.floor(Date.now() / 1000))

    getContext(this).eventHub.on('onEmitTimestamp', (timestamp: number) => {
      this.updateTimeLeft(timestamp)
    });
  }

  updateTimeLeft(timestamp: number) {
    this.timeLeft = this.updateInterval - (timestamp % this.updateInterval);

    if (this.timeLeft === this.updateInterval) {
      this.authenticator.getCode()
        .then((code) => {
          this.code = code;
        })
    }
  }
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

  emitTimestamp() {
    const timestamp = Math.floor(Date.now() / 1000);
    getContext(this).eventHub.emit('onEmitTimestamp', timestamp);
  }

  build() {
    Navigation() {
      List({ space: 10 }) {
        ForEach(this.authenticators, (item: AuthenticatorClass) => {
          ListItem() {
            AuthenticatorItem({ authenticator: item })
          }
        })
      }
      .height('100%')
      .width('100%')
      .listDirection(Axis.Vertical)
      .alignListItem(ListItemAlign.Center)
    }
    .height('100%')
    .width('100%')
    .title($r('app.string.mainPage_title'))
    .menus(this.menuItems)
    .backgroundColor($r('sys.color.gray_01'))
  }

  aboutToAppear(): void {
    setInterval(() => { this.emitTimestamp(); }, 1000);
  }

  onPageShow(): void {
    getAuthenticators()
      .then((authenticators) => {
        this.authenticators = authenticators;
      });
  }
}