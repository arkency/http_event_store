require 'json'

module HttpEventstore
  class InMemoryEs

    def initialize(endpoint, port, page_size)
      @endpoint = Endpoint.new(endpoint, port)
      @page_size = page_size
      @event_store = {}
      @projection_store = {}
    end
    attr_reader :endpoint, :page_size, :event_store, :projection_store

    def append_to_stream(stream_name, event_data, expected_version = nil)
      unless event_store.key?(stream_name)
        event_store[stream_name] = []
      end

      event_data.each do |event|
        id = event_store[stream_name].length
        event_store[stream_name].unshift({'eventId' => event.event_id, 'data' => event.data.to_json, 'eventType' => event.type, 'positionEventNumber' => id})
      end
    end

    # def append_events_to_stream(stream_name, events_data=[], expected_version = nil)
    #   unless event_store.key?(stream_name)
    #     event_store[stream_name] = []
    #   end
    #   events_data.each do |event_data|
    #     id = event_store[stream_name].length
    #     event_store[stream_name].unshift({'eventId' => event_data.event_id, 'data' => event_data.data.to_json, 'eventType' => event_data.type, 'positionEventNumber' => id})
    #   end
    # end

    def delete_stream(stream_name, hard_delete)
      event_store.delete(stream_name)
    end

    def read_stream_page(uri)
      params = uri.scan(/\/(\w+)\/(\d+)/)
      stream_name = params[0][0]
      last_index = params[0][1].to_i
      direction = params[1][0]
      count = params[1][1].to_i
      if direction == 'next'
        read_stream_backward(stream_name, last_index, count)
      else
        read_stream_forward(stream_name, last_index, count)
      end
    end

    def read_stream_backward(stream_name, start, count)
      if event_store.key?(stream_name)
        start_index = start == :head ? event_store[stream_name].length - 1 : start
        last_index = start_index - count
        entries = event_store[stream_name].select do |event|
          event['positionEventNumber'] > last_index && event['positionEventNumber'] <= start_index
        end
        { 'entries' => entries, 'links' => links(last_index, stream_name, 'next', entries, count)}
      end
    end

    def read_stream_forward(stream_name, start_index, count, long_pool = 0)
      if event_store.key?(stream_name)
        last_index = start_index + count
        entries = event_store[stream_name].reverse.select do |event|
          event['positionEventNumber'] < last_index && event['positionEventNumber'] >= start_index
        end
        { 'entries' => entries.reverse!, 'links' => links(last_index, stream_name, 'previous', entries, count)}
      end
    end

    def set_projection_state(projection_name, state)
      state_key = "/projection/#{projection_name}/state"
      projection_store[state_key] = state
    end

    def read_projection_page(key)
      projection_store[key]
    end

    def reset!
      @event_store = {}
    end

    def endpoint
      Endpoint.new('127.0.0.1', 2113)
    end

    private

    def links(batch_size, stream_name, direction, entries, count)
      if entries.empty? || batch_size < 0
        []
      else
        [{
             'uri' => "http://#{endpoint.url}/streams/#{stream_name}/#{batch_size}/#{direction}/#{count}",
             'relation' => direction
         }]
      end
    end

  end
end
