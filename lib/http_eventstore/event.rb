class Event < Struct.new(:type, :data, :event_id, :id)
  def initialize(type, data, event_id = nil, id = nil)
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
