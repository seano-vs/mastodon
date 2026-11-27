# frozen_string_literal: true

class REST::EventSerializer < ActiveModel::Serializer
  # Please update `app/javascript/mastodon/api_types/events.ts` when making changes to the attributes

  attributes :name, :starts_at, :time_zone, :location
end
