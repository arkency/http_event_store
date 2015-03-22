module HttpEventstore
  class AppendEventToStream

    def initialize(client)
      @client = client
    end

    def call(stream_name, event_type, event_data, expected_version = nil)
      raise IncorrectStreamData if data_incorrect?(stream_name, event_type, event_data)
      event = create_event(event_type, event_data)
      create_event_in_es(stream_name, event, expected_version)
    rescue ClientError => e
      raise WrongExpectedEventNumber if e.code == 400
      raise StreamAlreadyDeleted if e.code == 410
    end

    private
    attr_reader :client

    def create_event(event_type, event_data)
      Event.new(event_type, event_data)
    end

    def create_event_in_es(stream_name, event, expected_version)
      client.append_to_stream(stream_name, event, expected_version)
    end

    def data_incorrect?(stream_name, event_type, event_data)
      [stream_name, event_type, event_data].any? {|var| var.nil? || var.empty?}
    end
  end
end
