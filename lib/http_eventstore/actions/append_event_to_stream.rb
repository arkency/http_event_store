module HttpEventstore
  class AppendEventToStream

    def initialize(client)
      @client = client
    end

    def call(stream_name, event_type, event_data)
      raise IncorrectStreamData if data_incorrect?(stream_name, event_type, event_data)
      event = create_event(event_type, event_data)
      create_event_in_es(stream_name, event)
    end

    private
    attr_reader :client

    def create_event(event_type, event_data)
      Event.new(event_type, event_data)
    end

    def create_event_in_es(stream_name, event)
      client.append_to_stream(stream_name, event)
    end

    def data_incorrect?(stream_name, event_type, event_data)
      stream_name.nil? || event_data.nil? || event_type.nil?
    end
  end
end
