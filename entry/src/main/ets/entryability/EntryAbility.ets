import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { RelationalStore } from '../models/RelationalStore';
import { Preferences } from '../models/Preferences';
import { BusinessError } from '@kit.BasicServicesKit';
import { i18n } from '@kit.LocalizationKit';
import { PreferenceConstants } from '../models/PreferenceConstants';
import { EventConstants } from '../models/EventConstants';

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

    // 初始化数据存储，完成后通知页面刷新
    this.initStores();
  }

  private async initStores(): Promise<void> {
    await this.initRdbStore();
    await this.initPreferences();

    // 存储就绪后通知页面刷新验证器列表。
    // 系统应用锁等场景下进程可能在锁屏遮罩后被挂起，存储初始化完成晚于页面首次拉取数据，
    // 此时页面已注册该事件监听，收到事件后会重新拉取数据
    this.context.eventHub.emit(EventConstants.ON_UPDATE_AUTHENTICATORS);
  }

  private async initPreferences(): Promise<void> {
    try {
      await this.preferences.loadPreferences(this.context, preferencesName);
      console.log('Preferences acquired.');

      // 设置深色/浅色模式
      let colorMode = await this.preferences.get(PreferenceConstants.COLOR_MODE, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      this.context.getApplicationContext().setColorMode(colorMode as ConfigurationConstant.ColorMode)

      // 设置显示语言
      let prefLanguage = await this.preferences.get(PreferenceConstants.PREFERENCE_LANGUAGE, 'default');
      i18n.System.setAppPreferredLanguage(prefLanguage as string);
    } catch (error) {
      const err = error as BusinessError;
      console.error('Error getting preferences: ', err.code, err.message);
    }
  }

  private async initRdbStore(): Promise<void> {
    try {
      await this.rdbStore.loadRdbStore(this.context, storeConfig);
      console.log('RdbStore acquired.');

      await this.rdbStore.execute(tableCreationQuery);
      console.log('Successfully initialized RdbStore.');
    } catch (error) {
      const err = error as BusinessError;

      // 14800020：数据库损坏，删除后重建
      if (err.code == 14800020) {
        console.error('RdbStore corrupted, rebuilding: ', err.code, err.message);
        try {
          await relationalStore.deleteRdbStore(this.context, storeConfig.name);
          await this.rdbStore.loadRdbStore(this.context, storeConfig);
          await this.rdbStore.execute(tableCreationQuery);
          console.log('Successfully rebuilt RdbStore.');
        } catch (rebuildError) {
          const rebuildErr = rebuildError as BusinessError;
          console.error('Failed to rebuild RdbStore: ', rebuildErr.code, rebuildErr.message);
        }
      } else {
        console.error('Failed to initialize RdbStore: ', err.code, err.message);
      }
    }
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

    // 回到前台时刷新验证器列表（覆盖系统应用锁解锁后回到前台、
    // 首次启动时数据尚未就绪等场景）
    this.context.eventHub.emit(EventConstants.ON_UPDATE_AUTHENTICATORS);
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
