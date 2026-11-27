import type { Meta, StoryObj } from '@storybook/react-vite';

import type { ApiEventJSON } from '@/mastodon/api_types/events';

import { StatusEvent } from './event';

const event: ApiEventJSON = {
  name: 'Central Park cleanup',
  starts_at: '2026-12-05T15:30:00.000Z',
  time_zone: 'America/New_York',
  location: 'Bethesda Terrace, Central Park',
};

const meta = {
  title: 'Components/Status/StatusEvent',
  component: StatusEvent,
  args: {
    event,
    uri: 'https://example.com/users/alice/statuses/1',
    url: 'https://example.com/@alice/1',
  },
} satisfies Meta<typeof StatusEvent>;

export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const WithoutLocation: Story = {
  args: {
    event: { ...event, location: null },
  },
};

export const LongTitleAndLocation: Story = {
  args: {
    event: {
      ...event,
      name: 'Annual meeting of the Friends of Prospect Park, followed by a potluck dinner and live music at the Boathouse',
      location:
        'Prospect Park Boathouse, 101 East Drive, Brooklyn, NY 11225 (enter at Lincoln Road and Ocean Avenue)',
    },
  },
};
