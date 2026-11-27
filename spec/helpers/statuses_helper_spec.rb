# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusesHelper do
  describe 'status_text_summary' do
    context 'with blank text' do
      let(:status) { Status.new(spoiler_text: '') }

      it 'returns immediately with nil' do
        result = helper.status_text_summary(status)
        expect(result).to be_nil
      end
    end

    context 'with present text' do
      let(:status) { Status.new(spoiler_text: 'SPOILERS!!!') }

      it 'returns the content warning' do
        result = helper.status_text_summary(status)
        expect(result).to eq(I18n.t('statuses.content_warning', warning: 'SPOILERS!!!'))
      end
    end
  end

  describe '#media_summary' do
    subject { helper.media_summary(status) }

    let(:status) { Fabricate.build :status }

    before { %i(video audio image).each { |type| Fabricate.build :media_attachment, status:, type: } }

    it { is_expected.to eq('Attached: 1 image · 1 video · 1 audio') }
  end

  describe '#event_summary' do
    subject { helper.event_summary(event) }

    let(:event) { Fabricate.build(:event, starts_at: '2026-12-05T15:30:00Z', time_zone: 'America/New_York', location: 'Central Park') }

    it { is_expected.to eq('Central Park cleanup · Dec 05, 2026, 10:30 EST · Central Park') }

    context 'without a time zone or location' do
      let(:event) { Fabricate.build(:event, starts_at: '2026-12-05T15:30:00Z', time_zone: nil, location: nil) }

      it { is_expected.to eq('Central Park cleanup · Dec 05, 2026, 15:30 UTC') }
    end
  end

  describe '#status_description' do
    subject { helper.status_description(status) }

    let(:status) { Fabricate(:status, text: 'Bring gloves!') }

    before { Fabricate(:event, status:, starts_at: '2026-12-05T15:30:00Z', time_zone: 'America/New_York') }

    it { is_expected.to eq("Bring gloves!\n\nCentral Park cleanup · Dec 05, 2026, 10:30 EST · Central Park") }

    context 'with a content warning' do
      let(:status) { Fabricate(:status, text: 'Bring gloves!', spoiler_text: 'Cleanup') }

      it 'hides the event along with the text' do
        expect(subject).to_not include('Central Park cleanup')
      end
    end
  end

  describe 'visibility_icon' do
    context 'with a status that is public' do
      let(:status) { Status.new(visibility: 'public') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('globe')
      end
    end

    context 'with a status that is unlisted' do
      let(:status) { Status.new(visibility: 'unlisted') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('lock_open')
      end
    end

    context 'with a status that is private' do
      let(:status) { Status.new(visibility: 'private') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('lock')
      end
    end

    context 'with a status that is direct' do
      let(:status) { Status.new(visibility: 'direct') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('alternate_email')
      end
    end
  end
end
