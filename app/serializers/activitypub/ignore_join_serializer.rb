# frozen_string_literal: true

class ActivityPub::IgnoreJoinSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor
  attribute :join_uri, key: :object

  def id
    "#{ActivityPub::TagManager.instance.uri_for(object)}#ignores/#{Digest::SHA256.hexdigest(join_uri)}"
  end

  def type
    'Ignore'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def join_uri
    instance_options[:join_uri]
  end
end
