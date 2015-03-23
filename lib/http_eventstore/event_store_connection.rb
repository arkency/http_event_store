module HttpEventstore
  class EventStoreConnection

    def append_to_stream(stream_name, event_type, event_data, expected_version = nil)
      AppendEventToStream.new(client).call(stream_name, event_type, event_data, expected_version)
    end

    def delete_stream(stream_name, hard_delete = false)
      DeleteStream.new(client).call(stream_name, hard_delete)
    end

    def read_events_forward(stream_name, start, count)
      ReadStreamEventsForward.new(client).call(stream_name, start, count)
    end

    def read_events_backward(stream_name, start, count)
      ReadStreamEventsBackward.new(client).call(stream_name, start, count)
    end

    def read_all_events_forward(stream_name)
      ReadAllStreamEventsForward.new(client).call(stream_name)
    end

    def read_all_events_backward(stream_name)
      ReadAllStreamEventsBackward.new(client).call(stream_name)
    end

    private

    def client
      @client ||= ApiClient.new
    end
  end
end
