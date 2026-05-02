import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { secureRandomInt } from '../utils/SecureRandom';
import { Logger } from '../utils/Logger';

const TAG = 'Reminders';

export type ReminderPreset = '1h' | '1d' | '1w';

const PRESET_SECONDS: Record<ReminderPreset, number> = {
  '1h': 60 * 60,
  '1d': 24 * 60 * 60,
  '1w': 7 * 24 * 60 * 60
};

function safeString(context: Context, name: string, value?: number): string {
  try {
    if (typeof value === 'number') {
      return context.resourceManager.getStringByNameSync(name, value);
    }
    return context.resourceManager.getStringByNameSync(name);
  } catch (_error) {
    return '';
  }
}

export class Reminders {
  static async schedule(context: Context, noteText: string, preset: ReminderPreset): Promise<number | null> {
    const seconds = PRESET_SECONDS[preset];
    const request: reminderAgentManager.ReminderRequestTimer = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
      triggerTimeInSeconds: seconds,
      title: safeString(context, 'reminder_app_title'),
      content: noteText,
      expiredContent: noteText,
      notificationId: secureRandomInt(1000000),
      actionButton: [
        {
          title: safeString(context, 'action_cancel'),
          type: reminderAgentManager.ActionButtonType.ACTION_BUTTON_TYPE_CLOSE
        }
      ]
    };

    try {
      const id = await reminderAgentManager.publishReminder(request);
      return id;
    } catch (e) {
      const err = e as BusinessError;
      Logger.error(TAG, `schedule err code=${err.code} msg=${err.message}`);
      return null;
    }
  }

  static async cancel(id: number): Promise<void> {
    try {
      await reminderAgentManager.cancelReminder(id);
    } catch (e) {
      const err = e as BusinessError;
      Logger.error(TAG, `cancel err code=${err.code} msg=${err.message}`);
    }
  }
}
