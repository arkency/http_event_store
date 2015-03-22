require 'http_eventstore/configuration'
require 'http_eventstore/client/api_client'
require 'http_eventstore/client/connection'
require 'http_eventstore/client/errors_handler'
require 'http_eventstore/event_store_connection'
require 'http_eventstore/models/event'
require 'http_eventstore/models/page_url'
require 'http_eventstore/actions/append_event_to_stream'
require 'http_eventstore/actions/delete_stream'
require 'http_eventstore/actions/read_all_stream_events'
require 'http_eventstore/actions/read_all_stream_events_backward'
require 'http_eventstore/actions/read_all_stream_events_forward'
require 'http_eventstore/models/errors'

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
