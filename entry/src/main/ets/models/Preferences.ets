import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

export class Preferences {
  private static instance: Preferences;
  private preferences: preferences.Preferences | undefined = undefined;

  private constructor() {}

  public static getInstance(): Preferences {
    if (!Preferences.instance) {
      Preferences.instance = new Preferences();
    }
    return Preferences.instance;
  }

  public async loadPreferences(context: common.BaseContext, name: string) {
    this.preferences = await preferences.getPreferences(context, name);
  }

  public async set(key: string, value: preferences.ValueType) {
    if (this.preferences == undefined) throw new Error('Preferences not loaded.');

    await this.preferences.put(key, value);
    await this.preferences.flush();
  }

  public setSync(key: string, value: preferences.ValueType) {
    if (this.preferences == undefined) throw new Error('Preferences not loaded.');

    this.preferences.putSync(key, value);
    this.preferences.flush();
  }

  public async get(key: string, defaultValue?: preferences.ValueType): Promise<preferences.ValueType> {
    if (this.preferences == undefined) throw new Error('Preferences not loaded.');

    return await this.preferences.get(key, defaultValue);
  }

  public getSync(key: string, defaultValue?: preferences.ValueType): preferences.ValueType {
    if (this.preferences == undefined) throw new Error('Preferences not loaded.');

    return this.preferences.getSync(key, defaultValue);
  }

  public async delete(key: string) {
    if (this.preferences == undefined) throw new Error('Preferences not loaded.');

    await this.preferences.delete(key);
    await this.preferences.flush();
  }
}