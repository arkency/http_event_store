require 'spec_helper'

module HttpEventstore
  describe Connection do
    ENDPOINT  = 'localhost'
    PORT      = 2113
    PAGE_SIZE = 20

    let(:client) { InMemoryEs.new(ENDPOINT, PORT, PAGE_SIZE) }
    let(:events) { prepare_events }
    let(:stream_name) { 'teststream' }

    before(:each) do
      @connection = Connection.new do |config|
        config.endpoint   = ENDPOINT
        config.port       = PORT
        config.page_size  = PAGE_SIZE
      end
      allow(@connection).to receive(:client).and_return(client)
      client.reset!
    end

    specify 'can create new event in stream' do
      create_stream
      expect(client.event_store[stream_name].length).to eq 4
    end

    specify 'event creation raise error if expected version is incorrect' do
      allow(client).to receive(:append_to_stream).and_raise(ClientError.new(400))
      expect { @connection.append_to_stream(stream_name, 'event_type', 'event_data', 1) }.to raise_error(WrongExpectedEventNumber)
    end

    specify 'event creation raise error if stream doesnt exist' do
      allow(client).to receive(:append_to_stream).and_raise(ClientError.new(410))
      expect { @connection.append_to_stream(stream_name, 'event_type', 'event_data', 1) }.to raise_error(StreamAlreadyDeleted)
    end

    specify 'event creation raise error if method arguments are incorrect' do
      expect { @connection.append_to_stream('stream_name', 'event_type', nil) }.to raise_error(IncorrectStreamData)
      expect { @connection.append_to_stream('stream_name', nil, 'event_data') }.to raise_error(IncorrectStreamData)
      expect { @connection.append_to_stream(nil, 'event_type', 'event_data') }.to raise_error(IncorrectStreamData)
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
        @connection.append_to_stream(stream_name, event[:event_type], event[:data])
      end
    end

  end
end
