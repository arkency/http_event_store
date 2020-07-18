module HttpEventStore
  module Api
    class Client
      VDN_EVENTSTORE_EVENTS_JSON  = 'application/vnd.eventstore.events+json'.freeze
      JSON                        = 'application/json'.freeze

      VDN_EVENTSTORE_EVENTS_JSON_HEADERS  = { "accept" => VDN_EVENTSTORE_EVENTS_JSON, "content-type" => VDN_EVENTSTORE_EVENTS_JSON }.freeze
      JSON_HEADERS                        = { "accept" => JSON, "content-type" => JSON }.freeze

      def initialize(endpoint, port, page_size)
        @endpoint = Endpoint.new(endpoint, port)
        @page_size = page_size
      end
      attr_reader :endpoint, :page_size

      def append_to_stream(stream_name, event_data, expected_version = nil)
        headers =  VDN_EVENTSTORE_EVENTS_JSON_HEADERS.merge({"ES-ExpectedVersion" => "#{expected_version}"}.reject { |key, val| val.empty? })

        data = [event_data].flatten.map do |event|
          {
            eventId:   event.event_id,
            eventType: event.type,
            data:      event.data,
            metadata:  event.metadata
          }
        end

        make_request(:post, "/streams/#{stream_name}", data, headers)
      end

      def delete_stream(stream_name, hard_delete)
        headers = JSON_HEADERS.merge({"ES-HardDelete" => "#{hard_delete}"})
        make_request(:delete, "/streams/#{stream_name}", {}, headers)
      end

      def read_stream_backward(stream_name, start, count)
        make_request(:get, "/streams/#{stream_name}/#{start}/backward/#{count}", {}, JSON_HEADERS)
      end

      def read_stream_forward(stream_name, start, count, long_pool = 0)
        headers = long_pool > 0 ? JSON_HEADERS.merge({"ES-LongPoll" => "#{long_pool}"}) : JSON_HEADERS
        make_request(:get, "/streams/#{stream_name}/#{start}/forward/#{count}", {}, headers)
      end

      def read_stream_page(uri)
        make_request(:get, uri, {}, JSON_HEADERS)
      end
      alias_method :read_projection_page, :read_stream_page

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
