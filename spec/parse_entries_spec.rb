require 'spec_helper'

module HttpEventstore
  module Helpers
    describe ParseEntries do

      let(:service) { ParseEntries.new }

      specify 'return parsed events' do
        events = service.call(entries)
        expect(events.length).to eq 1
        expect(events[0].type).to eq "entryCreated"
        expect(events[0].data).to eq({"a" => "1"})
        expect(events[0].event_id).to eq "fbf4a1a1-b4a3-4dfe-a01f-6668634e16e4"
        expect(events[0].id).to eq 47
        expect(events[0].position).to eq 51
        expect(events[0].stream_name).to eq('entries')
        expect(events[0].created_time).to eq(Time.parse("2015-06-30T02:02:01Z"))
      end

      specify 'tolerates deleted stream events' do
        events = service.call(entries_including_deleted_stream_events)
        expect(events.length).to eq 1
        expect(events[0].type).to eq "entryCreated"
        expect(events[0].data).to eq({"a" => "1"})
        expect(events[0].event_id).to eq "fbf4a1a1-b4a3-4dfe-a01f-6668634e16e4"
        expect(events[0].id).to eq 47
        expect(events[0].position).to eq 51
        expect(events[0].stream_name).to eq('entries')
      end

      private

      def entries
        [entry]
      end

      def entries_including_deleted_stream_events
        [
          entry,
          deleted_stream_entry
        ]
      end


      def entry
        {
          "eventId" => "fbf4a1a1-b4a3-4dfe-a01f-6668634e16e4",
          "eventType" => "entryCreated",
          "data" => "{\n  \"a\": \"1\"\n}",
          "eventNumber" => 47,
          "positionEventNumber" => 51,
          "streamId" => 'entries',
          "updated" => "2015-06-30T02:02:01Z"
        }
      end

      def deleted_stream_entry
        {
          "title"=>"2147483647@entries-123",
          "id"=>"http://localhost:2113/streams/entries-123/2147483647",
          "updated"=>"2015-05-23T17:29:50.933926Z",
          "author"=>{"name"=>"EventStore"},
          "summary"=>"$>",
          "links"=>[{"uri"=>"http://localhost:2113/streams/entries-123/2147483647", "relation"=>"edit"}, {"uri"=>"http://localhost:2113/streams/entries-123/2147483647", "relation"=>"alternate"}]
        }
      end

    end
  end
end
