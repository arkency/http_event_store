module HttpEventstore
  module Actions
    class ReadStreamNewEventsForward < ReadAllStreamEvents
      def initialize(client, page_size)
        super(client)
        @start_point = 0
        @count = page_size
        @skip_old_events = true
        @previous_urls = {}
      end

      private
      attr_reader :start_point, :count

      def get_all_stream_entries(stream_name)
        feed = read_initial_feed(stream_name)
        last_url = find_link(feed, 'last')
        feed = read_events_by_uri(last_url) if last_url && @previous_urls[stream_name].nil?
        prev_url = find_link(feed,  'previous')
        @previous_urls[stream_name] = prev_url if prev_url

        if @skip_old_events
          @skip_old_events = false
          []
        else
          feed['entries'].reverse
        end
      end

      def read_initial_feed(stream_name)
        if @previous_urls[stream_name]
          read_events_by_uri @previous_urls[stream_name]
        else
          begin
            client.read_stream_forward(stream_name, start_point, count)
          rescue ClientError => e
            { 'links' => [], 'entries' => [] } # ignore client error for now
          end
        end
      end

      def read_events_by_uri(uri)
        client.read_stream_page uri
      end

      def find_link(feed, relation)
        (feed['links'].find { |link| link['relation'] == relation } || {})['uri']
      end
    end
  end
end
