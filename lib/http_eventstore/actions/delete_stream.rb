module HttpEventstore
  class DeleteStream

    def initialize(client)
      @client = client
    end

    def call(stream_name)
      raise IncorrectStreamData if stream_name.empty? || stream_name.nil?
      delete_stream(stream_name)
    end

    private
    attr_reader :client

    def delete_stream(stream_name)
      client.delete_stream(stream_name)
    end
  end
end
