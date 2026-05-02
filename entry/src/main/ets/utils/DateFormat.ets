const MINUTE = 60 * 1000;
const HOUR = 60 * MINUTE;
const DAY = 24 * HOUR;

function safeRelativeString(context: Context, key: string, value?: number): string {
  try {
    if (typeof value === 'number') {
      return context.resourceManager.getStringByNameSync(key, value);
    }
    return context.resourceManager.getStringByNameSync(key);
  } catch (_error) {
    if (typeof value === 'number') {
      return `${value}`;
    }
    return '';
  }
}

export function formatRelative(context: Context, timestamp: number, now: number = Date.now()): string {
  const diff = Math.max(0, now - timestamp);
  if (diff < MINUTE) {
    return safeRelativeString(context, 'time_just_now');
  }
  if (diff < HOUR) {
    return safeRelativeString(context, 'time_minutes_ago', Math.floor(diff / MINUTE));
  }
  if (diff < DAY) {
    return safeRelativeString(context, 'time_hours_ago', Math.floor(diff / HOUR));
  }
  if (diff < 7 * DAY) {
    return safeRelativeString(context, 'time_days_ago', Math.floor(diff / DAY));
  }
  const d = new Date(timestamp);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
