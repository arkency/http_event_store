module HttpEventstore
  module Helpers
    class ParseEntries

      def call(entries)
        entries.collect do |entry|
          create_event(entry)
        end
      end

      private

      def create_event(entry)
        id = entry['positionEventNumber']
        event_id = entry['eventId']
        type = entry['eventType']
        data = JSON.parse(entry['data'])
        stream_name = entry['streamId']
        Event.new(type, data, event_id, id, stream_name)
      end
    end
  end
end
