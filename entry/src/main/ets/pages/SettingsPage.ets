import Want from "@ohos.app.ability.Want";
import { common } from "@kit.AbilityKit";
import { SettingsSwitchItem } from "../components/SettingsSwitchItem";
import { Preferences } from "../models/Preferences";
import { window } from "@kit.ArkUI";

const preferences = Preferences.getInstance();

@Builder
export function settingsPageBuilder() {
  SettingsPage()
}

@Entry
@Component
struct SettingsPage {
  @State privacyMode: boolean = false;
  private windowClass = AppStorage.get('windowClass') as window.Window;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          List({ space: 16 }) {
            ListItemGroup() {
              SettingsSwitchItem({
                title: $r('app.string.SettingsPage_privacyMode'),
                description: $r('app.string.SettingsPage_privacyModeDescription'),
                isOn: this.privacyMode,
                onChange: this.onPrivacyModeChange
              })
            }
            .backgroundColor('white')
            .borderRadius(16)
            .padding({ left: 16, right: 16})
            .divider({ strokeWidth: 1, color: '#d2d2d2' })

            ListItemGroup() {
              ListItem() {
                Text($r('app.string.SettingsPage_privacyPolicy'))
                  .width('100%')
              }
              .padding({ top: 16, bottom: 16 })
              .onClick(() => {
                let context = getContext(this) as common.UIAbilityContext;
                let want: Want = {
                  action: 'ohos.want.action.viewData',
                  uri: 'https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=1573492775360423168'
                };
                context.startAbility(want);
              })
            }
            .backgroundColor('white')
            .borderRadius(16)
            .padding({ left: 16, right: 16})
            .divider({ strokeWidth: 1, color: '#d2d2d2' })
          }
        }
        .margin({ left: 16, right: 16 })
      }
      .height('100%')
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title(getContext(this).resourceManager.getStringSync($r('app.string.mainPageMenu_settings')))
    .backgroundColor($r('sys.color.gray_01'))
  }

  aboutToAppear(): void {
    this.privacyMode = preferences.getSync('privacyMode', true) as boolean;
  }

  onPrivacyModeChange = (isOn: boolean) => {
    console.log('isOn' + isOn)
    this.privacyMode = isOn;
    preferences.setSync('privacyMode', this.privacyMode);
    this.windowClass.setWindowPrivacyMode(isOn);
  }
}