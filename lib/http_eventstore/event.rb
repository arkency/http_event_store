class Event < Struct.new(:type, :data, :event_id, :id)
  def initialize(type, data, event_id = SecureRandom.uuid, id = nil); super end

  def to_json(options)
    self.to_h.to_json
  end
end
