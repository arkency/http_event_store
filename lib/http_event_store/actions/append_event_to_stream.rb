require 'ostruct'

module HttpEventStore
  module Actions
    class AppendEventToStream

      def initialize(client)
        @client = client
      end

      def call(stream_name, event_data, expected_version = nil)
        events = [event_data].flatten.map do |event_data|
          event_data = OpenStruct.new(event_data) if event_data.is_a?(Hash)
          event = create_event(event_data)
          raise IncorrectStreamData if event.validate || stream_name_incorrect?(stream_name)
          event
        end

        create_event_in_es(stream_name, events, expected_version)
      rescue ClientError => e
        raise WrongExpectedEventNumber if e.code == 400
        raise StreamAlreadyDeleted if e.code == 410
      end

      private
      attr_reader :client

      def create_event(event_data)
        type = event_data.event_type
        data = event_data.data
        meta_data = event_data.meta_data if event_data.respond_to?(:meta_data)
        event_id = event_data.event_id if event_data.respond_to?(:event_id)
        Event.new(type, data, meta_data, event_id)
      end

      def create_event_in_es(stream_name, event, expected_version)
        client.append_to_stream(stream_name, event, expected_version)
      end

      def stream_name_incorrect?(stream_name)
        stream_name.nil? || stream_name.empty?
      end
    end
  end
end
