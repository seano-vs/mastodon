# frozen_string_literal: true

# Parses the event-specific properties of an `Event` object, following
# FEP-8a8e: https://w3id.org/fep/8a8e
class ActivityPub::Parser::EventParser
  include JsonLdHelper

  def initialize(json)
    @json = json
  end

  def valid?
    equals_or_includes?(@json['type'], 'Event') && name.present? && starts_at.present?
  end

  def attributes
    { name:, starts_at:, time_zone:, location: }
  end

  def name
    name = @json['name'].presence || (@json['nameMap'].values.first if @json['nameMap'].is_a?(Hash))
    # Truncate rather than error out to avoid missing the post entirely
    name[0, Event::NAME_LENGTH_HARD_LIMIT] if name.is_a?(String)
  end

  def starts_at
    datetime = @json['startTime']&.to_datetime
    datetime if datetime.present? && (0..9999).cover?(datetime.year)
  rescue ArgumentError
    nil
  end

  def time_zone
    @json['timezone'] if @json['timezone'].is_a?(String)
  end

  # Only the first location is kept, as recommended for applications that do
  # not support multiple locations
  def location
    place = as_array(@json['location']).find { |item| item.is_a?(Hash) }
    return if place.nil?

    [place['name'], address(place['address'])].grep(String).compact_blank.uniq.join(', ')[0, Event::LOCATION_LENGTH_HARD_LIMIT].presence
  end

  private

  def address(value)
    case value
    when String
      value
    when Hash
      value.values_at('streetAddress', 'addressLocality', 'addressRegion', 'addressCountry').grep(String).compact_blank.join(', ')
    end
  end
end
