import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

const TAG = 'PreferencesUtil';
const PREFERENCE_NAME = 'myStore';

export class PreferencesUtil {
  private static preferencesUtil: PreferencesUtil;

  public static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.preferencesUtil) {
      PreferencesUtil.preferencesUtil = new PreferencesUtil();
    }
    return PreferencesUtil.preferencesUtil;
  }

  private async getPreferences(context: Context): Promise<preferences.Preferences> {
    try {
      const pref = await preferences.getPreferences(context, PREFERENCE_NAME);
      return pref;
    } catch (e) {
      const err = e as BusinessError;
      Logger.error(TAG, `getPreferences err code: ${err.code}, message: ${err.message}`);
      throw new Error(`getPreferences failed: ${err.message}`);
    }
  }

  public async putValue(context: Context, key: string, value: preferences.ValueType): Promise<void> {
    try {
      const pre = await this.getPreferences(context);
      await pre.put(key, value);
      await pre.flush();
      Logger.info(TAG, `putValue ok key=${key}`);
    } catch (e) {
      const err = e as BusinessError;
      Logger.error(TAG, `putValue err key=${key} code=${err.code} msg=${err.message}`);
    }
  }

  public async getValue(context: Context, key: string,
    defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    try {
      const pre = await this.getPreferences(context);
      const data = await pre.get(key, defaultValue);
      return data;
    } catch (e) {
      const err = e as BusinessError;
      Logger.error(TAG, `getValue err key=${key} code=${err.code} msg=${err.message}`);
      return defaultValue;
    }
  }

  public async putJson<T>(context: Context, key: string, value: T): Promise<void> {
    await this.putValue(context, key, JSON.stringify(value));
  }

  public async getJson<T>(context: Context, key: string, defaultValue: T): Promise<T> {
    const raw = await this.getValue(context, key, JSON.stringify(defaultValue));
    if (typeof raw !== 'string' || raw.length === 0) {
      return defaultValue;
    }
    try {
      return JSON.parse(raw) as T;
    } catch (e) {
      Logger.error(TAG, `getJson parse err key=${key}`);
      return defaultValue;
    }
  }

  public async remove(context: Context, key: string): Promise<void> {
    try {
      const pre = await this.getPreferences(context);
      await pre.delete(key);
      await pre.flush();
    } catch (e) {
      const err = e as BusinessError;
      Logger.error(TAG, `remove err key=${key} code=${err.code} msg=${err.message}`);
    }
  }
}
