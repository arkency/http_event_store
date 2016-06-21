module HttpEventStore
  class Endpoint

    def initialize(endpoint, port)
      @endpoint = endpoint
      @port = port
    end

    def url
      "http://#{endpoint}:#{port.to_s}"
    end

    private
    attr_reader :endpoint, :port
  end
end
