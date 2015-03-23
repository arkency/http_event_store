require 'spec_helper'

module HttpEventstore
  describe ApiClient do

    let(:client)      { ApiClient.new }
    let(:stream_name) { 'streamname' }

    before(:each) do
      HttpEventstore.configure do |config|
        config.long_pool_time = 10
      end
    end

    specify 'should add to response proper headers' do
      event = Event.new('event_type', {data: 1})
      expect(client).to receive(:make_request).with(:post, '/streams/streamname', {data: 1}, { 'ES-EventType' => 'event_type', 'ES-EventId' => event.event_id})
      client.append_to_stream(stream_name, event)
      expect(client).to receive(:make_request).with(:post, '/streams/streamname', {data: 1}, { 'ES-EventType' => 'event_type', 'ES-EventId' => event.event_id, 'ES-ExpectedVersion' => '1'})
      client.append_to_stream(stream_name, event, 1)
    end

    specify 'should add to response proper headers' do
      expect(client).to receive(:make_request).with(:delete, '/streams/streamname', {}, { 'ES-HardDelete' => 'false' })
      client.delete_stream(stream_name, false)
      expect(client).to receive(:make_request).with(:delete, '/streams/streamname', {}, { 'ES-HardDelete' => 'true' })
      client.delete_stream(stream_name, true)
    end

    specify 'should add to response proper headers' do
      expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/backward/20')
      client.read_stream_backward(stream_name, 0, 20)
    end

    specify 'should add to response proper headers' do
      expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/forward/20', {}, {})
      client.read_stream_forward(stream_name, 0, 20)
      expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/forward/20', {}, {"ES-LongPoll" => "10"})
      client.read_stream_forward(stream_name, 0, 20, true)
    end
  end
end

