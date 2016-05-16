module HttpEventstore
  module Actions
    class ReadAllStreamEventsBackward < ReadAllStreamEvents

      def initialize(client, page_size)
        super(client)
        @start_point = :head
        @count = page_size
      end

      private
      attr_reader :start_point, :count

      def append_entries(entries, batch)
        entries + batch
      end

      def get_stream_batch(stream_name, start)
        if start.nil?
          read_stream_backward(stream_name, start_point, count)
        else
          read_stream_by_url(start)
        end
      end

      def read_stream_backward(stream_name, next_id, count)
        client.read_stream_backward(stream_name, next_id, count)
      end

      def read_stream_by_url(uri)
        client.read_stream_page(uri)
      end

      def get_next_start_point(links)
        link = links.detect { |link| link['relation'] == 'next' }
        unless link.nil?
          link['uri'].slice! client.endpoint.url
          link['uri']
        end
      end
    end
  end
end
