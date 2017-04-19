require 'spec_helper'

module HttpEventStore
  module Api
    describe Client do

      let(:client)      { Client.new('localhost', 2113, 20) }
      let(:stream_name) { 'streamname' }

      describe '#append_to_stream' do

        it "should handle one event" do
          event = Event.new('event_type', { data: 1 }, nil, nil, nil, nil, nil, nil, { meta_data: 2})
          expect(client).to receive(:make_request).with(:post, '/streams/streamname', [{eventId: event.event_id, eventType: event.type, data: event.data, metadata: { meta_data: 2}}], {'accept' => 'application/vnd.eventstore.events+json', 'content-type' => 'application/vnd.eventstore.events+json'})
          client.append_to_stream(stream_name, event)
          expect(client).to receive(:make_request).with(:post, '/streams/streamname', [{eventId: event.event_id, eventType: event.type, data: event.data, metadata: { meta_data: 2}}], {'ES-ExpectedVersion' => '1', 'accept' => 'application/vnd.eventstore.events+json', 'content-type' => 'application/vnd.eventstore.events+json'})
          client.append_to_stream(stream_name, event, 1)
        end

        it "should handle more than one event" do
          event1 = Event.new('event-type', {data: 1})
          event2 = Event.new('event-type2', {data: 2})
          events = [event1, event2]

          expect(client).to receive(:make_request).with(:post, '/streams/streamname', [{eventId: event1.event_id, eventType: event1.type, data: event1.data, metadata: nil},{eventId: event2.event_id, eventType: event2.type, data: event2.data, metadata: nil}], {'ES-ExpectedVersion' => '1', 'accept' => 'application/vnd.eventstore.events+json', 'content-type' => 'application/vnd.eventstore.events+json'})
          client.append_to_stream(stream_name, events, 1)
        end
      end

      specify '#delete_stream' do
        expect(client).to receive(:make_request).with(:delete, '/streams/streamname', {}, {'accept' => 'application/json', 'content-type' => 'application/json', 'ES-HardDelete' => 'false'})
        client.delete_stream(stream_name, false)
        expect(client).to receive(:make_request).with(:delete, '/streams/streamname', {}, {'accept' => 'application/json', 'content-type' => 'application/json', 'ES-HardDelete' => 'true'})
        client.delete_stream(stream_name, true)
      end

      specify '#read_stream_backward' do
        expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/backward/20', {}, {'accept' => 'application/json', 'content-type' => 'application/json'})
        client.read_stream_backward(stream_name, 0, 20)
      end

      specify '#read_stream_forward' do
        expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/forward/20', {}, {'accept' => 'application/json', 'content-type' => 'application/json'})
        client.read_stream_forward(stream_name, 0, 20, 0)
        expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/forward/20', {}, {'accept' => 'application/json', 'content-type' => 'application/json', 'ES-LongPoll' => '10'})
        client.read_stream_forward(stream_name, 0, 20, 10)
      end

      specify '#read_stream_page' do
        expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/forward/20', {}, {'accept' => 'application/json', 'content-type' => 'application/json'})
        client.read_stream_page('/streams/streamname/0/forward/20')
      end
    end
  end
end

