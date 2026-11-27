import type { ApiEventJSON } from '@/mastodon/api_types/events';

/**
 * The event as it is edited in the compose form. Date and time are kept
 * as the raw values of the native `date` and `time` inputs.
 */
export interface ComposeEvent {
  name: string;
  date: string;
  time: string;
  location: string;
}

export type ComposeEventParams = Pick<ApiEventJSON, 'name' | 'starts_at'> & {
  time_zone: string;
  location: string;
};

const pad = (value: number) => value.toString().padStart(2, '0');

/**
 * Splits an ISO timestamp into values for the `date` and `time` inputs,
 * in the browser's time zone.
 */
export function startsAtToInputs(startsAt: string | Date) {
  const date = new Date(startsAt);

  return {
    date: `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`,
    time: `${pad(date.getHours())}:${pad(date.getMinutes())}`,
  };
}

export function emptyComposeEvent(now = new Date()): ComposeEvent {
  // Default to the next full hour, tomorrow
  const startsAt = new Date(now);
  startsAt.setDate(startsAt.getDate() + 1);
  startsAt.setHours(startsAt.getHours() + 1, 0, 0, 0);

  return { name: '', location: '', ...startsAtToInputs(startsAt) };
}

export function composeEventFromApi(event: ApiEventJSON): ComposeEvent {
  return {
    name: event.name,
    location: event.location ?? '',
    ...startsAtToInputs(event.starts_at),
  };
}

export function composeEventToParams(event: ComposeEvent): ComposeEventParams {
  // Without a time zone designator, the date is parsed as local time
  const startsAt = new Date(`${event.date}T${event.time}`);

  return {
    name: event.name,
    starts_at: startsAt.toISOString(),
    time_zone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    location: event.location,
  };
}

export function isComposeEventComplete(event: ComposeEvent) {
  return (
    event.name.trim().length > 0 &&
    !Number.isNaN(Date.parse(`${event.date}T${event.time}`))
  );
}
