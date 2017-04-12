module HttpEventStore
  class Connection
    attr_accessor :endpoint, :port, :page_size

    def initialize
      setup_defaults
      yield(self) if block_given?
    end

    def append_to_stream(stream_name, event_data, expected_version = nil)
      append_to_stream_action.call(stream_name, event_data, expected_version)
    end

    def delete_stream(stream_name, hard_delete = false)
      delete_stream_action.call(stream_name, hard_delete)
    end

    def read_events_forward(stream_name, start, count, pool = 0)
      read_events_forward_action.call(stream_name, start, count, pool)
    end

    def read_events_backward(stream_name, start, count)
      read_events_backward_action.call(stream_name, start, count)
    end

    def read_all_events_forward(stream_name)
      read_all_events_forward_action.call(stream_name)
    end

    def read_all_events_backward(stream_name)
      read_all_events_backward_action.call(stream_name)
    end

    def read_projection_state(projection_name)
      read_projection_state_action.call(projection_name)
    end

    def set_projection_state(projection_name, state)
      set_projection_state_action.call(projection_name, state)
    end

    private

    def append_to_stream_action
      @append_to_stream_action ||= Actions::AppendEventToStream.new(client)
    end

    def delete_stream_action
      @delete_stream_action ||= Actions::DeleteStream.new(client)
    end

    def read_events_forward_action
      @read_events_forward_action ||= Actions::ReadStreamEventsForward.new(client)
    end

    def read_events_backward_action
      @read_events_backward_action ||= Actions::ReadStreamEventsBackward.new(client)
    end

    def read_all_events_forward_action
      @read_all_events_forward_action ||= Actions::ReadAllStreamEventsForward.new(client, page_size)
    end

    def read_all_events_backward_action
      @read_all_events_backward_action ||= Actions::ReadAllStreamEventsBackward.new(client, page_size)
    end

    def read_projection_state_action
      @read_projection_state_action ||= Actions::ReadProjectionState.new(client)
    end

    def set_projection_state_action
      @set_projection_state_action ||= Actions::SetProjectionState.new(client)
    end

    def client
      @client ||= Api::Client.new(endpoint, port, page_size)
    end

    def setup_defaults
      @endpoint  = 'localhost'
      @port      = 2113
      @page_size = 20
    end

  end
end
