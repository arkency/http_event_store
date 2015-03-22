module HttpEventstore
  class ReadAllStreamEvents

    def initialize(client)
      @client = client
    end

    def call(stream_name)
      raise IncorrectStreamData if stream_name.nil? || stream_name.empty?
      entries = get_stream_entries(stream_name)
      return_events(entries)
    rescue ClientError => e
      raise StreamAlreadyDeleted if e.code == 410
      raise StreamNotExist if e.code == 404
    end

    private
    attr_reader :client

    def get_stream_entries(stream_name, start_point = nil, entries = [])
      stream_data = get_stream_data(stream_name, start_point)
      entries = append_entries(entries, stream_data['entries'])
      start_point = get_next_start_point(stream_data['links'], stream_name)
      return entries if start_point.nil?
      get_stream_entries(stream_name, start_point, entries)
    end

    def get_stream_data(stream_name, start_point)
      get_stream_batch(stream_name, start_point)
    end

    def return_events(entries)
      entries.collect do |entry|
        event_id = entry['eventId']
        type = entry['eventType']
        data = JSON.parse(entry['data'])
        Event.new(type, data, event_id)
      end
    end
  end
end
