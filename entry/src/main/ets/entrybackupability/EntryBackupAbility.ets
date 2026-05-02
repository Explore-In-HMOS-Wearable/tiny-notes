import { hilog } from '@kit.PerformanceAnalysisKit';
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';

const DOMAIN = 0x0000;
const TAG = 'TinyNotesBackup';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup(): Promise<void> {
    hilog.info(DOMAIN, TAG, 'onBackup start');
    await Promise.resolve();
    hilog.info(DOMAIN, TAG, 'onBackup done');
  }

  async onRestore(bundleVersion: BundleVersion): Promise<void> {
    hilog.info(DOMAIN, TAG, 'onRestore version %{public}s', JSON.stringify(bundleVersion));
    await Promise.resolve();
    hilog.info(DOMAIN, TAG, 'onRestore done');
  }
}
