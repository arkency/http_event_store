module HttpEventstore
  module Actions
    class ReadStreamEventsBackward

      def initialize(client)
        @client = client
      end

      def call(stream_name, start, count)
        response = get_stream_batch(stream_name, start, count)
        return_events(response['entries'])
      rescue ClientError => e
        raise StreamAlreadyDeleted if e.code == 410
        raise StreamNotFound if e.code == 404
      end

      private
      attr_reader :client

      def get_stream_batch(stream_name, start, count)
        client.read_stream_backward(stream_name, start, count)
      end

      def return_events(entries)
        Helpers::ParseEntries.new.call(entries)
      end
    end
  end
end
