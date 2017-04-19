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
        return nil unless entry['eventType']

        id               = entry['eventNumber']
        event_id         = entry['eventId']
        type             = entry['eventType']
        source_event_uri = entry['id']
        data             = !entry['data'].nil? && !entry['data'].empty? ? JSON.parse(entry['data']) : nil
        stream_name      = entry['streamId']
        position         = entry['positionEventNumber']
        created_time     = entry['updated'] ? Time.parse(entry['updated']) : nil
        meta_data        = !entry['meta_data'].nil? && !entry['meta_data'].empty? ? JSON.parse(entry['meta_data']) : nil

        Event.new(type, data, meta_data, source_event_uri, event_id, id, position, stream_name, created_time)
      end
    end
  end
end
