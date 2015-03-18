require 'json'

module HttpEventstore
  class InMemoryEs

    def initialize
      @event_store = {}
    end
    attr_reader :event_store

    def append_to_stream(stream_name, event_data)
      unless event_store.key?(stream_name)
        event_store[stream_name] = []
      end
      event_store[stream_name].unshift({'eventId' => event_data.event_id, 'data' => event_data.data.to_json, 'eventType' => event_data.type})
    end

    def delete_stream(stream_name)
      event_store.delete(stream_name)
    end

    def read_stream_backward(stream_name, start, count)
      start_index = start == :head ? 0 : start
      if event_store.key?(stream_name)
        batch_size = start_index + count
        entries = event_store[stream_name].select.with_index do |event, index|
          index < batch_size && index >= start_index
        end
        { 'entries' => entries, 'links' => links(batch_size, stream_name, 'next', entries)}
      end
    end

    def read_stream_forward(stream_name, start_index, count)
      if event_store.key?(stream_name)
        batch_size = start_index + count
        entries = event_store[stream_name].reverse.select.with_index do |event, index|
          index < batch_size && index >= start_index
        end
        { 'entries' => entries.reverse!, 'links' => links(batch_size, stream_name, 'previous', entries)}
      end
    end

    def reset!
      @event_store = {}
    end

    private

    def links(batch_size, stream_name, direction, entries)
      if entries.empty?
        []
      else
        [{
             'uri' => "http://127.0.0.1:2113/strams/#{stream_name}/#{batch_size}/direction/3",
             'relation' => direction
         }]
      end
    end

  end
end
