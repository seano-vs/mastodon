import { useMemo } from 'react';

import { FormattedDate, FormattedMessage } from 'react-intl';

import {
  CalendarBlankIcon,
  CalendarPlusIcon,
  MapPinIcon,
} from '@phosphor-icons/react';

import type { ApiEventJSON } from '@/mastodon/api_types/events';
import { eventToICalendar } from '@/mastodon/utils/icalendar';

import { Icon } from '../icon';

import classes from './event.module.scss';

export const StatusEvent: React.FC<{
  event: ApiEventJSON;
  uri: string;
  url: string | null;
}> = ({ event, uri, url }) => {
  const calendarHref = useMemo(
    () =>
      `data:text/calendar;charset=utf-8,${encodeURIComponent(
        eventToICalendar(event, { uid: uri, url: url ?? uri }),
      )}`,
    [event, uri, url],
  );

  return (
    <div className={classes.event}>
      <strong className={classes.name}>{event.name}</strong>

      <p className={classes.detail}>
        <Icon id='calendar' icon={CalendarBlankIcon} aria-hidden />
        <time dateTime={event.starts_at}>
          <FormattedDate
            value={event.starts_at}
            weekday='long'
            year='numeric'
            month='long'
            day='numeric'
            hour='numeric'
            minute='2-digit'
            timeZoneName='short'
          />
        </time>
      </p>

      {event.location && (
        <p className={classes.detail}>
          <Icon id='map-pin' icon={MapPinIcon} aria-hidden />
          <span>{event.location}</span>
        </p>
      )}

      <a
        className={classes.addToCalendar}
        href={calendarHref}
        download='event.ics'
      >
        <Icon id='calendar-plus' icon={CalendarPlusIcon} aria-hidden />
        <FormattedMessage
          id='status.event.add_to_calendar'
          defaultMessage='Add to calendar'
        />
      </a>
    </div>
  );
};
