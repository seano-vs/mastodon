# frozen_string_literal: true

Fabricator(:event) do
  status { Fabricate.build(:status) }
  name { 'Central Park cleanup' }
  starts_at { 3.days.from_now.change(usec: 0) }
  time_zone 'America/New_York'
  location 'Central Park'
end
