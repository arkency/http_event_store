require 'spec_helper'

module HttpEventstore
  describe EventStoreConnection do

    let(:service) { ParseEntries.new }

    specify 'return parsed events' do
      events = service.call(entries)
      expect(events.length).to eq 1
      expect(events[0].type).to eq "entryCreated"
      expect(events[0].data).to eq({"a"=>"1"})
      expect(events[0].event_id).to eq "fbf4a1a1-b4a3-4dfe-a01f-6668634e16e4"
      expect(events[0].id).to eq 47
    end

    private

    def entries
      [{"eventId"=>"fbf4a1a1-b4a3-4dfe-a01f-6668634e16e4",
        "eventType"=>"entryCreated",
        "data"=>"{\n  \"a\": \"1\"\n}",
        "positionEventNumber"=>47,
       }]
    end

  end
end
