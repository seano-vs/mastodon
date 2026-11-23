# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Parser::EventParser do
  subject { described_class.new(json) }

  let(:json) do
    {
      'type' => 'Event',
      'name' => 'Central Park cleanup',
      'startTime' => '2026-12-31T23:00:00Z',
      'timezone' => 'America/New_York',
      'location' => {
        'type' => 'Place',
        'name' => 'Central Park',
        'address' => {
          'type' => 'PostalAddress',
          'streetAddress' => '830 5th Ave',
          'addressLocality' => 'New York',
          'addressRegion' => 'NY',
          'addressCountry' => 'US',
        },
      },
    }
  end

  it 'parses the event attributes' do
    expect(subject).to be_valid
    expect(subject.attributes).to eq(
      name: 'Central Park cleanup',
      starts_at: '2026-12-31T23:00:00Z'.to_datetime,
      time_zone: 'America/New_York',
      location: 'Central Park, 830 5th Ave, New York, NY, US'
    )
  end

  context 'with a plain text address and several locations' do
    let(:json) { super().merge('location' => [{ 'type' => 'Place', 'name' => 'Central Park', 'address' => '830 5th Ave' }, { 'type' => 'VirtualLocation', 'name' => 'Stream' }]) }

    it 'keeps the first location only' do
      expect(subject.location).to eq 'Central Park, 830 5th Ave'
    end
  end

  context 'without a name' do
    let(:json) { super().except('name') }

    it { is_expected.to_not be_valid }
  end

  context 'with an invalid start time' do
    let(:json) { super().merge('startTime' => 'tomorrow-ish') }

    it { is_expected.to_not be_valid }
  end

  context 'with a start time outside of the supported range' do
    let(:json) { super().merge('startTime' => '10000-01-01T00:00:00Z') }

    it { is_expected.to_not be_valid }
  end

  context 'with a name that is not a string' do
    let(:json) { super().merge('name' => { 'en' => 'Central Park cleanup' }) }

    it { is_expected.to_not be_valid }
  end

  context 'with a name and location over the hard limits' do
    let(:json) { super().merge('name' => 'a' * 300, 'location' => { 'type' => 'Place', 'name' => 'b' * 3000 }) }

    it 'truncates them' do
      expect(subject.name.length).to eq Event::NAME_LENGTH_HARD_LIMIT
      expect(subject.location.length).to eq Event::LOCATION_LENGTH_HARD_LIMIT
    end
  end

  context 'with a name map' do
    let(:json) { super().except('name').merge('nameMap' => { 'es' => 'Limpieza de Central Park' }) }

    it 'uses the first name' do
      expect(subject.name).to eq 'Limpieza de Central Park'
    end
  end

  context 'with a location that is not a string' do
    let(:json) { super().merge('location' => { 'type' => 'Place', 'name' => ['Central Park'], 'address' => { 'addressLocality' => 42 } }) }

    it 'ignores it' do
      expect(subject.location).to be_nil
    end
  end

  context 'when the object is not an event' do
    let(:json) { super().merge('type' => 'Note') }

    it { is_expected.to_not be_valid }
  end
end
