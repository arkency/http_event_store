module HttpEventstore
  class Configuration
    attr_accessor :endpoint
    attr_accessor :port
    attr_accessor :page_size

    def initialize
      @endpoint = '127.0.0.1'
      @port = 2113
      @page_size = 20
    end

    def get_store_url
      "http://#{@endpoint}:#{@port.to_s}"
    end
  end
end
