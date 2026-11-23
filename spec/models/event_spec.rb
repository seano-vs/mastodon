# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  describe 'Normalizations' do
    it { is_expected.to normalize(:name).from("  Central\n Park  cleanup ").to('Central Park cleanup') }
    it { is_expected.to normalize(:location).from('  ').to(nil) }
    it { is_expected.to normalize(:time_zone).from('America/New_York').to('America/New_York') }
    it { is_expected.to normalize(:time_zone).from('Not/AZone').to(nil) }
  end

  describe 'Validations' do
    subject { Fabricate.build(:event) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_length_of(:name).is_at_most(described_class::NAME_LENGTH_LOCAL_LIMIT) }
    it { is_expected.to validate_length_of(:location).is_at_most(described_class::LOCATION_LENGTH_LOCAL_LIMIT) }

    context 'when the status is remote' do
      subject { Fabricate.build(:event, status: Fabricate.build(:status, uri: 'https://example.com/statuses/1')) }

      it { is_expected.to validate_length_of(:name).is_at_most(described_class::NAME_LENGTH_HARD_LIMIT) }
      it { is_expected.to validate_length_of(:location).is_at_most(described_class::LOCATION_LENGTH_HARD_LIMIT) }
    end

    context 'when the status also has a poll' do
      subject { Fabricate.build(:event, status:) }

      let(:status) { Fabricate.build(:status).tap { |status| status.poll = Fabricate.build(:poll, status:) } }

      it { is_expected.to_not be_valid }
    end
  end
end
