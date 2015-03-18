module HttpEventstore
  class ReadAllStreamEventsBackward < ReadAllStreamEvents

    def initialize(client)
      super(client)
      @start_point = :head
      @count = HttpEventstore.configuration.page_size
    end

    private
    attr_reader :start_point, :count

    def append_entries(entries, batch)
      entries + batch
    end

    def get_stream_batch(stream_name, start = nil)
      next_id = start.nil? ? start_point : start
      client.read_stream_backward(stream_name, next_id, count)
    end

    def get_next_start_point(links, stream_name)
      PageUrl.new(links, stream_name).next
    end
  end
end
