module HttpEventstore
  class ApiClient

    def append_to_stream(stream_name, stream_data)
      make_request(:post, "/streams/#{stream_name}", stream_data)
    end

    def delete_stream(stream_name)
      make_request(:delete, "/streams/#{stream_name}")
    end

    def read_stream_page(page_url)
      make_request(:get, page_url + "?embed=body")
    end

    def read_stream_backward(stream_name, start, count)
      make_request(:get, "/streams/#{stream_name}/#{start}/backward/#{count}?embed=body")
    end

    def read_stream_forward(stream_name, start, count)
      make_request(:get, "/streams/#{stream_name}/#{start}/forward/#{count}?embed=body")
    end

    private

    def make_request(method, path, body={}, headers={})
      connection.send(method, path) do |req|
        req.headers = req.headers.merge(headers)
        req.body = body.to_json
      end.body
    end

    def connection
      Connection.new.call
    end
  end
end
