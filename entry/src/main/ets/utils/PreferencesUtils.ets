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

  private getPreferences(context: Context): Promise<preferences.Preferences> {
    return new Promise((resolve, reject) => {
      preferences.getPreferences(context, PREFERENCE_NAME).then((pref: preferences.Preferences) => {
        Logger.info(TAG, `getPreferences successfully.`);
        resolve(pref);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `getPreferences err code: ${err.code},message: ${err.message}`);
        reject(err);
      })
    })
  }

  private preferencesFlush(preferences: preferences.Preferences) {
    preferences.flush().then(() => {
      Logger.info(TAG, `preferencesFlush successfully.`);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `preferencesFlush err code: ${err.code},message: ${err.message}`);
    })
  }

  public async putValue(context: Context, key: string, value: preferences.ValueType) {
    Logger.info(`putValue key: ${key},value: ${value}`);
    let pre = await this.getPreferences(context);
    pre.put(key, value).then(() => {
      this.preferencesFlush(pre);
      Logger.info(TAG, `putValue successfully.`);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `putValue err code: ${err.code},message: ${err.message}`);
    })
  }

  public async getValue(context: Context, key: string,
    defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    let pre = await this.getPreferences(context);
    return new Promise((resolve, reject) => {
      pre.get(key, defaultValue).then((data: preferences.ValueType) => {
        Logger.info(TAG, `getValue successfully,value: ${data.toString()}`);
        resolve(data);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `getValue err code: ${err.code},message: ${err.message}`);
        reject(err);
      })
    })
  }

}