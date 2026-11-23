import {
  composeEventFromApi,
  composeEventToParams,
  emptyComposeEvent,
  isComposeEventComplete,
  startsAtToInputs,
} from './event';

describe('emptyComposeEvent', () => {
  test('defaults to the next full hour, tomorrow', () => {
    expect(emptyComposeEvent(new Date(2026, 10, 23, 14, 35))).toEqual({
      name: '',
      location: '',
      date: '2026-11-24',
      time: '15:00',
    });
  });
});

describe('startsAtToInputs', () => {
  test('round-trips with composeEventToParams', () => {
    const startsAt = new Date(2026, 11, 31, 9, 5);
    const inputs = startsAtToInputs(startsAt);

    expect(inputs).toEqual({ date: '2026-12-31', time: '09:05' });
    expect(
      composeEventToParams({ name: 'Summer concert', location: '', ...inputs })
        .starts_at,
    ).toBe(startsAt.toISOString());
  });
});

describe('composeEventFromApi', () => {
  test('fills in a missing location', () => {
    const event = composeEventFromApi({
      name: 'Summer concert',
      starts_at: new Date(2026, 11, 31, 20).toISOString(),
      time_zone: null,
      location: null,
    });

    expect(event).toEqual({
      name: 'Summer concert',
      location: '',
      date: '2026-12-31',
      time: '20:00',
    });
  });
});

describe('composeEventToParams', () => {
  test("includes the browser's time zone", () => {
    expect(
      composeEventToParams({
        name: 'Summer concert',
        location: 'Prospect Park Bandshell',
        date: '2026-12-31',
        time: '20:00',
      }).time_zone,
    ).toBe(Intl.DateTimeFormat().resolvedOptions().timeZone);
  });
});

describe('isComposeEventComplete', () => {
  const event = {
    name: 'Summer concert',
    location: '',
    date: '2026-12-31',
    time: '20:00',
  };

  test('requires a title', () => {
    expect(isComposeEventComplete(event)).toBe(true);
    expect(isComposeEventComplete({ ...event, name: '  ' })).toBe(false);
  });

  test('requires a date and a time', () => {
    expect(isComposeEventComplete({ ...event, date: '' })).toBe(false);
    expect(isComposeEventComplete({ ...event, time: '' })).toBe(false);
  });
});
