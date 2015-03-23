module HttpEventstore
  class ApiClient

    def append_to_stream(stream_name, event, expected_version = nil)
      headers = { "ES-EventType" => event.type, "ES-EventId" => event.event_id, "ES-ExpectedVersion" => "#{expected_version}" }.reject{|key,val| val.empty?}
      make_request(:post, "/streams/#{stream_name}", event.data, headers)
    end

    def delete_stream(stream_name, hard_delete)
      headers = { "ES-HardDelete" => "#{hard_delete}" }
      make_request(:delete, "/streams/#{stream_name}", {}, headers)
    end

    def read_stream_backward(stream_name, start, count)
      make_request(:get, "/streams/#{stream_name}/#{start}/backward/#{count}")
    end

    def read_stream_forward(stream_name, start, count, long_pool = false)
      headers = long_pool == true ? { "ES-LongPoll" => "#{HttpEventstore.configuration.long_pool_time}" } : {}
      make_request(:get, "/streams/#{stream_name}/#{start}/forward/#{count}", {}, headers)
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
      @connection ||= Connection.new.call
    end

  end
end
