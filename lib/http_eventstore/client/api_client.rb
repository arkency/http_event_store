module HttpEventstore
  class ApiClient

    def append_to_stream(stream_name, event)
      make_request(:post, "/streams/#{stream_name}", event.data, {"ES-EventType" => event.type, "ES-EventId" => event.event_id})
    end

    def delete_stream(stream_name)
      make_request(:delete, "/streams/#{stream_name}")
    end

    def read_stream_backward(stream_name, start, count)
      make_request(:get, "/streams/#{stream_name}/#{start}/backward/#{count}")
    end

    def read_stream_forward(stream_name, start, count)
      make_request(:get, "/streams/#{stream_name}/#{start}/forward/#{count}")
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
      Connection.new.call
    end
  end
end
