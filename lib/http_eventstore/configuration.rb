module HttpEventstore
  class Configuration
    attr_accessor :endpoint
    attr_accessor :port
    attr_accessor :page_size
    attr_accessor :long_pool_time

    def initialize
      @endpoint = '127.0.0.1'
      @port = 2113
      @page_size = 20
      @long_pool_time = 15
    end

    def get_store_url
      "http://#{@endpoint}:#{@port.to_s}"
    end
  end
end
