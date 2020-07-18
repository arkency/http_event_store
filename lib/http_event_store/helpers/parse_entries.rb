require 'time'

module HttpEventStore
  module Helpers
    class ParseEntries

      def call(entries)
        entries.collect do |entry|
          create_event(entry)
        end.compact
      end

      private

      def create_event(entry)
        return nil unless entry['data']

        id               = entry['eventNumber']
        event_id         = entry['eventId']
        type             = entry['eventType']
        source_event_uri = entry['id']
        data             = !entry['data'].nil? && !entry['data'].empty? ? JSON.parse(entry['data']) : {}
        stream_name      = entry['streamId']
        position         = entry['positionEventNumber']
        created_time     = entry['updated'] ? Time.parse(entry['updated']) : nil
        metadata         = !entry['metadata'].nil? && !entry['metadata'].empty? ? JSON.parse(entry['metadata']) : {}

        Event.new(type, data, metadata, source_event_uri, event_id, id, position, stream_name, created_time)
      end
    end
  end
end
