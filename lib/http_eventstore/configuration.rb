module HttpEventstore
  class Configuration
    attr_accessor :host
    attr_accessor :port

    def initialize
      @host = '127.0.0.1'
      @port = 2113
    end
  end
end
