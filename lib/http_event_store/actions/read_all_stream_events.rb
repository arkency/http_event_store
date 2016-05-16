module HttpEventstore
  module Actions
    class ReadAllStreamEvents

      def initialize(client)
        @client = client
      end

      def call(stream_name)
        raise IncorrectStreamData if stream_name.nil? || stream_name.empty?
        entries = get_all_stream_entries(stream_name)
        return_events(entries)
      rescue ClientError => e
        raise StreamAlreadyDeleted if e.code == 410
        raise StreamNotFound if e.code == 404
      end

      private
      attr_reader :client

      def get_all_stream_entries(stream_name, start_point = nil, entries = [])
        loop do
          start_point, entries = get_next_stream_entries(stream_name, start_point, entries)
          break if start_point.nil?
        end
        entries
      end

      def get_next_stream_entries(stream_name, start_point = nil, entries = [])
        stream_data = get_stream_batch(stream_name, start_point)
        entries = append_entries(entries, stream_data['entries'])
        start_point = get_next_start_point(stream_data['links'])
        [start_point, entries]
      end

      def return_events(entries)
        Helpers::ParseEntries.new.call(entries)
      end
    end
  end
end
