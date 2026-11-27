import { eventToICalendar } from './icalendar';

describe('eventToICalendar', () => {
  const event = {
    name: 'Central Park cleanup; bring gloves, bags',
    starts_at: '2026-12-05T15:30:00.000Z',
    time_zone: 'America/New_York',
    location: 'Central Park',
  };
  const ids = {
    uid: 'https://example.com/users/alice/statuses/1',
    url: 'https://example.com/@alice/1',
  };

  test('builds a single event calendar', () => {
    expect(
      eventToICalendar(event, ids, new Date('2026-11-23T12:00:00Z')).split(
        '\r\n',
      ),
    ).toEqual([
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Mastodon//Event//EN',
      'BEGIN:VEVENT',
      'UID:https://example.com/users/alice/statuses/1',
      'DTSTAMP:20261123T120000Z',
      'DTSTART:20261205T153000Z',
      'SUMMARY:Central Park cleanup\\; bring gloves\\, bags',
      'LOCATION:Central Park',
      'URL:https://example.com/@alice/1',
      'END:VEVENT',
      'END:VCALENDAR',
    ]);
  });

  test('folds lines longer than 75 octets', () => {
    const lines = eventToICalendar(
      { ...event, name: 'é'.repeat(50), location: 'x'.repeat(100) },
      ids,
    ).split('\r\n');

    expect(lines).toContain(`SUMMARY:${'é'.repeat(33)}`);
    expect(lines).toContain(` ${'é'.repeat(17)}`);
    expect(lines).toContain(`LOCATION:${'x'.repeat(66)}`);
    expect(lines).toContain(` ${'x'.repeat(34)}`);
    lines.forEach((line) => {
      expect(new TextEncoder().encode(line).length).toBeLessThanOrEqual(75);
    });
  });

  test('leaves out a missing location', () => {
    expect(eventToICalendar({ ...event, location: null }, ids)).not.toContain(
      'LOCATION',
    );
  });
});
