require 'securerandom'

class Event < Struct.new(:type, :data, :source_event_uri, :event_id, :id, :position, :stream_name, :created_time)
  def initialize(type, data, source_event_uri=nil, event_id=nil, id=nil, position=nil, stream_name=nil, created_time=nil)
    event_id = SecureRandom.uuid if event_id.nil?
    super
  end

  def validate
    [self.event_id, self.type, self.data].any? { |var| var.nil? || var.empty? }
  end

  def to_json(options)
    self.to_h.to_json
  end
end
