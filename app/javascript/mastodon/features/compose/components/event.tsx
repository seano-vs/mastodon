import type React from 'react';
import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import {
  changeComposeEvent,
  removeComposeEvent,
} from '@/mastodon/actions/compose_typed';
import { Button } from '@/mastodon/components/button';
import { TextInputField } from '@/mastodon/components/form_fields';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import type { ComposeEvent } from '../util/event';

import classes from './attachments.module.scss';
import { selectComposeEvent, selectComposeEventLimits } from './selectors';

const messages = defineMessages({
  namePlaceholder: {
    id: 'compose.event.name_placeholder',
    defaultMessage: 'Event title',
  },
  locationPlaceholder: {
    id: 'compose.event.location_placeholder',
    defaultMessage: 'Where is it happening?',
  },
});

export const ComposeEventForm: React.FC = () => {
  const event = useAppSelector(selectComposeEvent);
  const { maxNameLength, maxLocationLength } = useAppSelector(
    selectComposeEventLimits,
  );
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const handleChange: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    ({ target }) => {
      dispatch(
        changeComposeEvent({
          [target.name as keyof ComposeEvent]: target.value,
        }),
      );
    },
    [dispatch],
  );

  const handleDelete = useCallback(() => {
    dispatch(removeComposeEvent());
  }, [dispatch]);

  if (!event) {
    return null;
  }

  return (
    <div className={classes.event}>
      <TextInputField
        name='name'
        label={
          <FormattedMessage id='compose.event.name' defaultMessage='Title' />
        }
        placeholder={intl.formatMessage(messages.namePlaceholder)}
        value={event.name}
        onChange={handleChange}
        maxLength={maxNameLength}
        autoComplete='off'
        autoFocus
        compact
        required
      />

      <div className={classes.eventWhen}>
        <TextInputField
          type='date'
          name='date'
          label={
            <FormattedMessage id='compose.event.date' defaultMessage='Date' />
          }
          value={event.date}
          onChange={handleChange}
          compact
          required
        />

        <TextInputField
          type='time'
          name='time'
          label={
            <FormattedMessage id='compose.event.time' defaultMessage='Time' />
          }
          value={event.time}
          onChange={handleChange}
          compact
          required
        />
      </div>

      <TextInputField
        name='location'
        label={
          <FormattedMessage
            id='compose.event.location'
            defaultMessage='Location'
          />
        }
        placeholder={intl.formatMessage(messages.locationPlaceholder)}
        value={event.location}
        onChange={handleChange}
        maxLength={maxLocationLength}
        compact
        required={false}
      />

      <Button
        variant='ghost'
        color='destructive'
        size='xs'
        className={classes.eventDelete}
        onClick={handleDelete}
      >
        <FormattedMessage
          id='compose.event.delete'
          defaultMessage='Remove event'
        />
      </Button>
    </div>
  );
};
