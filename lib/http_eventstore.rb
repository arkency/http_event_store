require 'http_eventstore/version'
require 'http_eventstore/configuration'
require 'http_eventstore/api_client'

module HttpEventstore
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
