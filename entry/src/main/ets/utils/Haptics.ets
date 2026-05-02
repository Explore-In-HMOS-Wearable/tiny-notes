import { vibrator } from '@kit.SensorServiceKit';
import { Logger } from './Logger';
import { Limits } from '../constants/StorageKeys';

const TAG = 'Haptics';

export class Haptics {
  static tap(): void {
    Haptics.vibrate(Limits.HAPTIC_MS);
  }

  static strong(): void {
    Haptics.vibrate(Limits.HAPTIC_MS * 2);
  }

  private static vibrate(ms: number): void {
    try {
      vibrator.startVibration(
        { type: 'time', duration: ms },
        { id: 0, usage: 'touch' }
      ).catch((err: Error) => {
        Logger.error(TAG, `vibrate err: ${err.message}`);
      });
    } catch (e) {
      const err = e as Error;
      Logger.error(TAG, `vibrate sync err: ${err.message}`);
    }
  }
}
