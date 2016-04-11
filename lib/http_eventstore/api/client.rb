module HttpEventstore
  module Api
    class Client

      def initialize(endpoint, port, page_size)
        @endpoint = Endpoint.new(endpoint, port)
        @page_size = page_size
      end
      attr_reader :endpoint, :page_size

      def append_to_stream(stream_name, event, expected_version = nil)
        headers = {"ES-EventType" => event.type, "ES-EventId" => event.event_id, "ES-ExpectedVersion" => "#{expected_version}"}.reject { |key, val| val.empty? }
        make_request(:post, "/streams/#{stream_name}", event.data, headers)
      end

      def append_events_to_stream(stream_name, events=[], expected_version = nil)
        headers = {"ES-ExpectedVersion" => "#{expected_version}"}.reject { |key, val| val.empty? }

        data = events.map do |event|
          {
            "eventId": event.event_id,
            "eventType": event.type,
            "data": event.data
          }
        end

        make_request(:post, "/streams/#{stream_name}", data, headers)
      end

      def delete_stream(stream_name, hard_delete)
        headers = {"ES-HardDelete" => "#{hard_delete}"}
        make_request(:delete, "/streams/#{stream_name}", {}, headers)
      end

      def read_stream_backward(stream_name, start, count)
        make_request(:get, "/streams/#{stream_name}/#{start}/backward/#{count}")
      end

      def read_stream_forward(stream_name, start, count, long_pool = 0)
        headers = long_pool > 0 ? {"ES-LongPoll" => "#{long_pool}"} : {}
        make_request(:get, "/streams/#{stream_name}/#{start}/forward/#{count}", {}, headers)
      end

      def read_stream_page(uri)
        make_request(:get, uri)
      end

      private

      def make_request(method, path, body={}, headers={})
        connection.send(method, path) do |req|
          req.headers = req.headers.merge(headers)
          req.body = body.to_json
          req.params['embed'] = 'body' if method == :get
        end.body
      end

      def connection
        @connection ||= Api::Connection.new(endpoint).call
      end
    end
  end
end
