import type { ApiEventJSON } from '@/mastodon/api_types/events';

const MAX_LINE_LENGTH = 75;

const encoder = new TextEncoder();

// See https://datatracker.ietf.org/doc/html/rfc5545#section-3.3.11
const escapeText = (text: string) =>
  text.replace(/[\\;,]/g, '\\$&').replace(/\r?\n/g, '\\n');

// e.g. 20261205T093000Z
const formatDateTime = (date: string | Date) =>
  new Date(date).toISOString().replace(/[-:]|\.\d{3}/g, '');

// Lines longer than 75 octets must be folded, by continuing them on the
// next line after a single space.
// See https://datatracker.ietf.org/doc/html/rfc5545#section-3.1
const foldLine = (line: string) => {
  const lines: string[] = [];
  let current = '';
  let size = 0;

  for (const char of line) {
    const charSize = encoder.encode(char).length;

    if (size + charSize > MAX_LINE_LENGTH) {
      lines.push(current);
      current = ' ';
      size = 1;
    }

    current += char;
    size += charSize;
  }

  return [...lines, current].join('\r\n');
};

/**
 * Builds a minimal iCalendar file for a single event, suitable for
 * importing into calendar applications.
 */
export function eventToICalendar(
  event: ApiEventJSON,
  { uid, url }: { uid: string; url: string },
  now = new Date(),
) {
  return [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Mastodon//Event//EN',
    'BEGIN:VEVENT',
    `UID:${uid}`,
    `DTSTAMP:${formatDateTime(now)}`,
    `DTSTART:${formatDateTime(event.starts_at)}`,
    `SUMMARY:${escapeText(event.name)}`,
    ...(event.location ? [`LOCATION:${escapeText(event.location)}`] : []),
    `URL:${url}`,
    'END:VEVENT',
    'END:VCALENDAR',
  ]
    .map(foldLine)
    .join('\r\n');
}
