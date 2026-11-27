// See app/serializers/rest/event_serializer.rb

export interface ApiEventJSON {
  name: string;
  starts_at: string;
  time_zone: string | null;
  location: string | null;
}
