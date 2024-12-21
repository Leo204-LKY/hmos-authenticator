import Want from '@ohos.app.ability.Want';
import { ConfigurationConstant, Context } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { SettingsSwitchItem } from '../components/SettingsSwitchItem';
import { Preferences } from '../models/Preferences';
import { EditableTitleBar, window } from '@kit.ArkUI';
import { ListItemGroupHeader } from '../components/ListItemGroupHeader';
import { SettingsSelectItem } from '../components/SettingsSelectItem';
import { i18n } from '@kit.LocalizationKit';

const preferences = Preferences.getInstance();

const languageMap: Map<ResourceStr, string> = new Map<ResourceStr, string>([
  [$r('app.string.language_default'), 'default'],
  ['简体中文', 'zh-Hans-CN'],
  ['English', 'en-Latn-US']
])

const colorModeMap: Map<ResourceStr, ConfigurationConstant.ColorMode> = new Map<ResourceStr, ConfigurationConstant.ColorMode>([
  [$r('app.string.SettingsPage_colorModeSystem'), ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET],
  [$r('app.string.SettingsPage_colorModeLight'), ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT],
  [$r('app.string.SettingsPage_colorModeDark'), ConfigurationConstant.ColorMode.COLOR_MODE_DARK]
])

@Builder
export function settingsPageBuilder() {
  SettingsPage()
}

@Entry
@Component
struct SettingsPage {
  @Consume('navPathStack') navPathStack: NavPathStack
  @State privacyMode: boolean = false;
  @State selectedLanguageIndex: number = -1;
  @State selectedLanguageValue: ResourceStr = '';
  @State selectedColorModeIndex: number = -1;
  @State selectedColorModeValue: ResourceStr = '';
  @State currentPreferredLanguage: string = 'default';
  private appContext = getContext(this).getApplicationContext()
  private windowClass = AppStorage.get('windowClass') as window.Window;

  build() {
    NavDestination() {
      Column() {
        EditableTitleBar({
          title: $r('app.string.SettingsPage_title'),
          onCancel: () => { this.navPathStack.pop(); },
          isSaveIconRequired: false
        })
      }

      Scroll() {
        Column() {
          List() {
            // 安全
            ListItemGroupHeader({ text: $r('app.string.SettingsPage_securityHeader') })
            ListItemGroup() {
              SettingsSwitchItem({
                title: $r('app.string.SettingsPage_privacyMode'),
                description: $r('app.string.SettingsPage_privacyModeDescription'),
                isOn: this.privacyMode,
                onChange: this.onPrivacyModeChange
              })
            }
            .backgroundColor($r('app.color.background_secondary'))
            .borderRadius(16)
            .padding({ left: 16, right: 16})
            .divider({ strokeWidth: 1, color: $r('app.color.divider') })

            // 外观
            ListItemGroupHeader({ text: $r('app.string.SettingsPage_appearanceHeader') })
            ListItemGroup() {
              SettingsSelectItem({
                title: $r('app.string.SettingsPage_language'),
                optionsText: Array.from(languageMap.keys()),
                selectedIndex: this.selectedLanguageIndex,
                onSelect: this.onLanguageChange,
                value: this.selectedLanguageValue
              })
              SettingsSelectItem({
                title: $r('app.string.SettingsPage_darkMode'),
                optionsText: Array.from(colorModeMap.keys()),
                selectedIndex: this.selectedColorModeIndex,
                onSelect: this.onColorModeChange,
                value: this.selectedColorModeValue
              })
            }
            .backgroundColor($r('app.color.background_secondary'))
            .borderRadius(16)
            .padding({ left: 16, right: 16})
            .divider({ strokeWidth: 1, color: $r('app.color.divider') })

            // 关于
            ListItemGroupHeader({ text: $r('app.string.SettingsPage_aboutHeader') })
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
            .backgroundColor($r('app.color.background_secondary'))
            .borderRadius(16)
            .padding({ left: 16, right: 16})
            .divider({ strokeWidth: 1, color: $r('app.color.divider') })
          }
        }
        .margin({ left: 16, right: 16 })
      }
      .height('100%')
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_primary'))
  }

  aboutToAppear(): void {
    preferences.get('privacyMode', true)
      .then((privacyMode) => {
        this.privacyMode = privacyMode as boolean;
      });

    preferences.get('colorMode', ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
      .then((colorMode) => {
        this.selectedColorModeIndex = Array.from(colorModeMap.values()).indexOf(colorMode as ConfigurationConstant.ColorMode);
        this.selectedColorModeValue = Array.from(colorModeMap.keys())[this.selectedColorModeIndex];
      })

    let preferredLanguage = i18n.System.getAppPreferredLanguage();
    this.currentPreferredLanguage = preferredLanguage
    this.selectedLanguageIndex = Array.from(languageMap.values()).indexOf(preferredLanguage);
    this.selectedLanguageValue = Array.from(languageMap.keys())[this.selectedLanguageIndex];
  }

  onPrivacyModeChange = (isOn: boolean) => {
    console.log('isOn' + isOn)
    this.privacyMode = isOn;
    preferences.setSync('privacyMode', this.privacyMode);
    this.windowClass.setWindowPrivacyMode(isOn);
  }

  onLanguageChange = (index: number) => {
    let newPreferredLanguage = Array.from(languageMap.values())[index];
    console.log('Setting language to ' + newPreferredLanguage);
    if (this.currentPreferredLanguage != newPreferredLanguage) {
      if (newPreferredLanguage == 'default') {
        // 设置为系统默认语言的操作会在重启 App 后生效，因此先设置一次语言
        i18n.System.setAppPreferredLanguage(i18n.System.getSystemLanguage())
      }
      i18n.System.setAppPreferredLanguage(newPreferredLanguage);
      this.currentPreferredLanguage = newPreferredLanguage;
    }
  }

  onColorModeChange = (index: number) => {
    let newColorMode = Array.from(colorModeMap.values())[index];
    preferences.set('colorMode', newColorMode)
      .then(() => {
        this.appContext.setColorMode(newColorMode);
      });
  }
}