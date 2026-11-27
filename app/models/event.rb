# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id         :bigint(8)        not null, primary key
#  location   :string
#  name       :string           not null
#  starts_at  :datetime         not null
#  time_zone  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status_id  :bigint(8)        not null
#

class Event < ApplicationRecord
  NAME_LENGTH_LOCAL_LIMIT = 100
  NAME_LENGTH_HARD_LIMIT = 256
  LOCATION_LENGTH_LOCAL_LIMIT = 200
  LOCATION_LENGTH_HARD_LIMIT = 2048

  belongs_to :status, inverse_of: :event

  normalizes :name, :location, with: ->(value) { value.squish.presence }
  normalizes :time_zone, with: ->(time_zone) { ActiveSupport::TimeZone[time_zone].nil? ? nil : time_zone }

  validates :name, :starts_at, presence: true
  validates :name, length: { maximum: NAME_LENGTH_LOCAL_LIMIT }, if: :local?
  validates :name, length: { maximum: NAME_LENGTH_HARD_LIMIT }, unless: :local?
  validates :location, length: { maximum: LOCATION_LENGTH_LOCAL_LIMIT }, if: :local?
  validates :location, length: { maximum: LOCATION_LENGTH_HARD_LIMIT }, unless: :local?
  validate :validate_no_poll, if: :local?

  delegate :local?, to: :status

  private

  def validate_no_poll
    errors.add(:base, I18n.t('events.errors.poll_conflict')) if status.poll.present?
  end
end
