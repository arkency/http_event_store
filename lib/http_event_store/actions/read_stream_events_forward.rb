module HttpEventstore
  module Actions
    class ReadStreamEventsForward

      def initialize(client)
        @client = client
      end

      def call(stream_name, start, count, pool)
        response = get_stream_batch(stream_name, start, count, pool)
        return_events(response['entries'])
      rescue ClientError => e
        raise StreamAlreadyDeleted if e.code == 410
        raise StreamNotFound if e.code == 404
      end

      private
      attr_reader :client

      def get_stream_batch(stream_name, start, count, pool)
        client.read_stream_forward(stream_name, start, count, pool)
      end

      def return_events(entries)
        Helpers::ParseEntries.new.call(entries)
      end
    end
  end
end
