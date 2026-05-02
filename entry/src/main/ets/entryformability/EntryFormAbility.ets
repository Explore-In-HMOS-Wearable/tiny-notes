import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { PreferencesUtil } from '../utils/PreferencesUtils';
import { NotesRepository } from '../data/NotesRepository';
import { StorageKeys } from '../constants/StorageKeys';
import { Logger } from '../utils/Logger';

const TAG = 'EntryFormAbility';

export default class EntryFormAbility extends FormExtensionAbility {
  private async getFormIds(): Promise<string[]> {
    const raw = await PreferencesUtil.getInstance().getJson<string[]>(this.context, StorageKeys.FORM_IDS, []);
    if (Array.isArray(raw) && raw.length > 0) {
      return raw.filter((item: string) => typeof item === 'string' && item.length > 0);
    }

    const legacy = await PreferencesUtil.getInstance().getValue(this.context, StorageKeys.FORM_ID, '');
    if (typeof legacy === 'string' && legacy.length > 0) {
      const migrated = [legacy];
      await PreferencesUtil.getInstance().putJson(this.context, StorageKeys.FORM_IDS, migrated);
      return migrated;
    }

    return [];
  }

  private async saveFormIds(formIds: string[]): Promise<void> {
    if (formIds.length === 0) {
      await Promise.all([
        PreferencesUtil.getInstance().remove(this.context, StorageKeys.FORM_IDS),
        PreferencesUtil.getInstance().remove(this.context, StorageKeys.FORM_ID)
      ]);
      return;
    }

    await Promise.all([
      PreferencesUtil.getInstance().putJson(this.context, StorageKeys.FORM_IDS, formIds),
      PreferencesUtil.getInstance().putValue(this.context, StorageKeys.FORM_ID, formIds[formIds.length - 1])
    ]);
  }

  onAddForm(want: Want) {
    let formId = '';
    if (want.parameters) {
      formId = want.parameters['ohos.extra.param.key.form_identity'] as string;
      if (formId) {
        this.getFormIds()
          .then((formIds: string[]) => {
            if (formIds.indexOf(formId) >= 0) {
              return formIds;
            }
            return formIds.concat(formId);
          })
          .then((formIds: string[]) => this.saveFormIds(formIds))
          .catch((err: Error) => Logger.error(TAG, `save formId failed: ${err.message}`));
      }
    }

    NotesRepository.getInstance().getPinnedText(this.context)
      .then(text => {
        if (!formId) {
          return;
        }
        const data = formBindingData.createFormBindingData({
          text: text && text.length > 0 ? text : ''
        });
        formProvider.updateForm(formId, data);
      })
      .catch((err: Error) => Logger.error(TAG, `initial pinned load failed: ${err.message}`));

    return formBindingData.createFormBindingData({ text: '' });
  }

  onCastToNormalForm(formId: string) {
  }

  onUpdateForm(formId: string) {
    NotesRepository.getInstance().getPinnedText(this.context)
      .then(text => {
        const data = formBindingData.createFormBindingData({
          text: text && text.length > 0 ? text : ''
        });
        return formProvider.updateForm(formId, data);
      })
      .catch((err: Error) => Logger.error(TAG, `onUpdateForm err: ${err.message}`));
  }

  onRemoveForm(formId: string) {
    this.getFormIds()
      .then((formIds: string[]) => formIds.filter((item: string) => item !== formId))
      .then((formIds: string[]) => this.saveFormIds(formIds))
      .catch((err: Error) => Logger.error(TAG, `clear formId failed: ${err.message}`));
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY;
  }
}
