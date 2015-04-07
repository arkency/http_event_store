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
      end

      private

      def entries
        [{"eventId" => "fbf4a1a1-b4a3-4dfe-a01f-6668634e16e4",
          "eventType" => "entryCreated",
          "data" => "{\n  \"a\": \"1\"\n}",
          "eventNumber" => 47,
          "positionEventNumber" => 51,
          "streamId" => 'entries'
         }]
      end
    end
  end
end
