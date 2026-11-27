# frozen_string_literal: true

# Mastodon does not handle RSVPs, so as recommended by FEP-8a8e, any `Join`
# targeting a local event is answered with an `Ignore`
class ActivityPub::Activity::Join < ActivityPub::Activity
  include Payloadable

  def perform
    return if non_matching_uri_hosts?(@account.uri, @json['id'])

    status = status_from_uri(object_uri)
    return if status.nil? || !status.local? || !status.with_event? || !StatusPolicy.new(@account, status).show?

    json = serialize_payload(status, ActivityPub::IgnoreJoinSerializer, join_uri: @json['id']).to_json
    ActivityPub::DeliveryWorker.perform_async(json, status.account_id, @account.inbox_url)
  end
end
