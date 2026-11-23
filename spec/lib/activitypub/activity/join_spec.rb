# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Join do
  subject { described_class.new(json, sender) }

  let(:sender) { Fabricate(:account, domain: 'example.com', inbox_url: 'https://example.com/inbox') }
  let(:status) { Fabricate(:status, visibility: :public) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/joins/1',
      type: 'Join',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(status),
    }.deep_stringify_keys
  end

  describe '#perform' do
    context 'when the object is a local event' do
      before { Fabricate(:event, status: status) }

      it 'answers with an Ignore activity' do
        expect { subject.perform }
          .to enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
          .with(match_json_values(type: 'Ignore', object: 'https://example.com/joins/1'), status.account_id, sender.inbox_url)
      end
    end

    context 'when the object is a local post without an event' do
      it 'does not answer' do
        expect { subject.perform }
          .to_not enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
      end
    end

    context 'when the event is not visible to the sender' do
      let(:status) { Fabricate(:status, visibility: :private) }

      before { Fabricate(:event, status: status) }

      it 'does not answer' do
        expect { subject.perform }
          .to_not enqueue_sidekiq_job(ActivityPub::DeliveryWorker)
      end
    end
  end
end
