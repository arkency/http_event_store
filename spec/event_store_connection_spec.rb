require 'spec_helper'

module HttpEventStore
  describe Connection do
    ENDPOINT  = 'localhost'
    PORT      = 2113
    PAGE_SIZE = 20
    DEFAULT_STATE = {foo: :bar}

    let(:client) { InMemoryEs.new(ENDPOINT, PORT, PAGE_SIZE) }
    let(:events) { prepare_events }
    let(:stream_name) { 'teststream' }

    before(:each) do
      @connection = Connection.new do |config|
        config.endpoint   = ENDPOINT
        config.port       = PORT
        config.page_size  = PAGE_SIZE
      end
      allow(Api::Client).to receive(:new).with(ENDPOINT, PORT, PAGE_SIZE).and_return(client)
      client.reset!
    end

    specify 'can create connection with default configuration' do
      default_connection = Connection.new
      expect(default_connection.endpoint).to eq ENDPOINT
      expect(default_connection.port).to eq PORT
      expect(default_connection.page_size).to eq PAGE_SIZE
    end

    specify 'can create new event in stream from hash' do
      create_event_in_es({ event_type: 'event_type', data: 'event_data' })
      expect(client.event_store[stream_name].length).to eq 1
    end

    specify 'can create new event with metadata in stream from hash' do
      create_event_in_es({ event_type: 'event_type', data: 'event_data', metadata: "event_metadata" })
      expect(client.event_store[stream_name][0]["metadata"]).to eq "\"event_metadata\""
    end

    specify 'can create new event in stream from array' do
      create_events_in_es([{ event_type: 'event_type', data: 'event_data' }])
      expect(client.event_store[stream_name].length).to eq 1
    end

    specify 'can create two new events in stream from array' do
      create_events_in_es([{ event_type: 'event_type', data: 'event_data' },{ event_type: 'event_type', data: 'event_data' }])
      expect(client.event_store[stream_name].length).to eq 2
    end

    specify 'can create new event in stream from struct' do
      EventData = Struct.new(:event_type, :data)
      event_data = EventData.new('event_type', 'event_data')
      create_event_in_es(event_data)
      expect(client.event_store[stream_name].length).to eq 1
    end

    specify 'can create event with no event data' do
      create_events_in_es({ event_type: 'event_type', data: {} })
      expect(client.event_store[stream_name].length).to eq 1
    end

    specify 'event creation raise error if expected version is incorrect' do
      allow(client).to receive(:append_to_stream).and_raise(ClientError.new(400))
      expect { create_event_in_es({ event_type: 'event_type', data: 'event_data' }) }.to raise_error(WrongExpectedEventNumber)
    end

    specify 'event creation raise error if stream doesnt exist' do
      allow(client).to receive(:append_to_stream).and_raise(ClientError.new(410))
      expect { create_event_in_es({ event_type: 'event_type', data: 'event_data' }) }.to raise_error(StreamAlreadyDeleted)
    end

    specify 'event creation raise error if method arguments are incorrect' do
      expect { create_event_in_es({ event_type: nil, data: 'event_data' }) }.to raise_error(IncorrectStreamData)
      expect { @connection.append_to_stream(nil, { event_type: 'event_type', data: 'event_data' }) }.to raise_error(IncorrectStreamData)
    end

    specify 'can deleted stream in es' do
      create_stream
      expect(client.event_store[stream_name].length).to eq 4
      @connection.delete_stream(stream_name)
      expect(client.event_store[stream_name]).to eq nil
    end

    specify 'event creation raise error if method arguments are incorrect' do
      expect { @connection.delete_stream(nil) }.to raise_error(IncorrectStreamData)
      expect { @connection.delete_stream('') }.to raise_error(IncorrectStreamData)
    end

    specify 'can load all events backward' do
      create_stream
      events = @connection.read_all_events_backward(stream_name)
      expect(events[0][:type]).to eq 'EventType4'
      expect(events[1][:type]).to eq 'EventType3'
      expect(events[2][:type]).to eq 'EventType2'
      expect(events[3][:type]).to eq 'EventType1'
    end

    specify 'can load all events forward' do
      create_stream
      events = @connection.read_all_events_forward(stream_name)
      expect(events[0][:type]).to eq 'EventType1'
      expect(events[1][:type]).to eq 'EventType2'
      expect(events[2][:type]).to eq 'EventType3'
      expect(events[3][:type]).to eq 'EventType4'
    end

    specify 'can read a projection' do
      create_projection('TestProjection')
      projection_name = 'TestProjection'
      state = @connection.read_projection_state(projection_name)
      expect(state).to eq DEFAULT_STATE
    end

    specify 'event creation raise error if method arguments are incorrect' do
      allow(client).to receive(:read_stream_forward).and_raise(ClientError.new(410))
      allow(client).to receive(:read_stream_backward).and_raise(ClientError.new(410))
      expect { @connection.read_all_events_forward(stream_name) }.to raise_error(StreamAlreadyDeleted)
      expect { @connection.read_all_events_backward(stream_name) }.to raise_error(StreamAlreadyDeleted)
    end

    specify 'event creation raise error if method arguments are incorrect' do
      allow(client).to receive(:read_stream_forward).and_raise(ClientError.new(404))
      allow(client).to receive(:read_stream_backward).and_raise(ClientError.new(404))
      expect { @connection.read_all_events_forward(stream_name) }.to raise_error(StreamNotFound)
      expect { @connection.read_all_events_backward(stream_name) }.to raise_error(StreamNotFound)
    end

    specify 'can load events forward' do
      create_stream
      events = @connection.read_events_forward(stream_name, 1, 3)
      expect(events[0][:type]).to eq 'EventType4'
      expect(events[1][:type]).to eq 'EventType3'
      expect(events[2][:type]).to eq 'EventType2'
    end

    specify 'can load events backward' do
      create_stream
      events = @connection.read_events_backward(stream_name, 3, 3)
      expect(events[0][:type]).to eq 'EventType4'
      expect(events[1][:type]).to eq 'EventType3'
      expect(events[2][:type]).to eq 'EventType2'
    end

    private

    def prepare_events
      [
          {event_type: 'EventType1', data: {id: 1}},
          {event_type: 'EventType2', data: {id: 2}},
          {event_type: 'EventType3', data: {id: 3}},
          {event_type: 'EventType4', data: {id: 4}}
      ]
    end

    def create_stream
      events.each do |event|
        @connection.append_to_stream(stream_name, event)
      end
    end

    def create_projection(projection_name, projection_state=DEFAULT_STATE)
      @connection.set_projection_state(projection_name, projection_state)
    end

    def create_event_in_es(event_data)
      @connection.append_to_stream(stream_name, event_data)
    end

    def create_events_in_es(events_data)
      @connection.append_to_stream(stream_name, events_data)
    end

  end
end
