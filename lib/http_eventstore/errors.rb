module HttpEventstore
  class ClientError < StandardError
    attr_accessor :code
    def initialize(code, msg = nil)
      @code = code
      super(msg)
    end
  end
  class ServerError < StandardError
    attr_accessor :code
    def initialize(code, msg = nil)
      @code = code
      super(msg)
    end
  end
  IncorrectStreamData       = Class.new(StandardError)
  WrongExpectedEventNumber  = Class.new(StandardError)
  StreamAlreadyDeleted      = Class.new(StandardError)
  StreamNotFound            = Class.new(StandardError)
end
