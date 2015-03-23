module HttpEventstore
  class ReadStreamEventsForward

    def initialize(client)
      @client = client
    end

    def call(stream_name, start, count)
      response = get_stream_batch(stream_name, start, count)
      return_events(response['entries'])
    rescue ClientError => e
      raise StreamAlreadyDeleted if e.code == 410
      raise StreamNotExist if e.code == 404
    end

    private
    attr_reader :client

    def get_stream_batch(stream_name, start, count)
      client.read_stream_forward(stream_name, start, count, true)
    end

    def return_events(entries)
      ParseEntries.new.call(entries)
    end
  end
end
