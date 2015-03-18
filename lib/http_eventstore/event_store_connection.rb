module HttpEventstore
  class EventStoreConnection

    def append_to_stream(stream_name, event_type, event_data)
      AppendEventToStream.new(client).call(stream_name, event_type, event_data)
    end

    def delete_stream(stream_name)
      DeleteStream.new(client).call(stream_name)
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
