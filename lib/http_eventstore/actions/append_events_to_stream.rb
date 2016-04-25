require 'ostruct'

module HttpEventstore
  module Actions
    class AppendEventsToStream

      def initialize(client)
        @client = client
      end

      def call(stream_name, events_data=[], expected_version = nil)

        events = events_data.map do |event_data|
          event_data = OpenStruct.new(event_data) if event_data.is_a?(Hash)
          event = create_event(event_data)
          raise IncorrectStreamData if event.validate || stream_name_incorrect?(stream_name)
          event
        end
        create_events_in_es(stream_name, events, expected_version)
      rescue ClientError => e
        raise WrongExpectedEventNumber if e.code == 400
        raise StreamAlreadyDeleted if e.code == 410
      end

      private
      attr_reader :client

      def create_event(event_data)
        type = event_data.event_type
        data = event_data.data
        event_id = event_data.event_id if event_data.respond_to?(:event_id)
        HttpEventstore::Event.new(type, data, event_id)
      end

      def create_events_in_es(stream_name, events, expected_version)
        client.append_events_to_stream(stream_name, events, expected_version)
      end

      def stream_name_incorrect?(stream_name)
        stream_name.nil? || stream_name.empty?
      end
    end
  end
end
