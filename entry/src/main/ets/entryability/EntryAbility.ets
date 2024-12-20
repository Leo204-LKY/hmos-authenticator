import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { preferences, relationalStore } from '@kit.ArkData';
import { RelationalStore } from '../models/RelationalStore'
import { Preferences } from '../models/Preferences'
import { BusinessError } from '@kit.BasicServicesKit';

const storeConfig: relationalStore.StoreConfig = {
  name: 'authenticators.db',
  securityLevel: relationalStore.SecurityLevel.S4
};

const tableCreationQuery: string = 'CREATE TABLE IF NOT EXISTS authenticator (' +
  'id INTEGER PRIMARY KEY, ' +
  'issuer TEXT NOT NULL, ' +
  'account TEXT DEFAULT NULL, ' +
  'secret TEXT NOT NULL, ' +
  'otp_type TEXT NOT NULL DEFAULT \'TOTP\', ' +
  'algorithm TEXT NOT NULL DEFAULT \'SHA1\', ' +
  'digits INTEGER NOT NULL DEFAULT 6, ' +
  'update_interval INTEGER NOT NULL DEFAULT 30);';

const preferencesName: string = 'authenticator'

export default class EntryAbility extends UIAbility {
  private rdbStore: RelationalStore = RelationalStore.getInstance();
  private preferences: Preferences = Preferences.getInstance();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // 获取数据库
    this.rdbStore.loadRdbStore(this.context, storeConfig)
      .then(() => {
        console.log('RdbStore acquired.');

        // 初始化数据库
        this.rdbStore.execute(tableCreationQuery)
          .then(() => {
            console.log('Successfully initialized RdbStore.');
          })
          .catch((error: BusinessError) => {
            console.error('Failed to initialize RdbStore: ' + error);
            return;
          });
      })
      .catch((error: BusinessError) => {
        console.error('Error getting RdbStore: ', error);
        return;
      });

    // 获取 preferences
    this.preferences.loadPreferences(this.context, preferencesName)
      .then(() => {
        console.log('Preferences acquired.');
      })
      .catch((error: BusinessError) => {
        console.error('Error getting preferences: ' + error);
        return;
      });

    // 设置深色模式
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // let privacyMode = this.preferences.getSync('privacyMode', true) as boolean;
    let windowClass = windowStage.getMainWindowSync();
    AppStorage.setOrCreate('windowClass', windowClass)

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
