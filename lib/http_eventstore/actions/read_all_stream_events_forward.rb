module HttpEventstore
  class ReadAllStreamEventsForward < ReadAllStreamEvents

    def initialize(client)
      super(client)
      @start_point = 0
      @count = HttpEventstore.configuration.page_size
    end

    private
    attr_reader :start_point, :count

    def append_entries(entries, batch)
      entries + batch.reverse!
    end

    def get_stream_batch(stream_name, start = nil)
      next_id = start.nil? ? start_point : start
      client.read_stream_forward(stream_name, next_id, count)
    end

    def get_next_start_point(links, stream_name)
      PageUrl.new(links, stream_name).previous
    end
  end
end
