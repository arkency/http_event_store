module HttpEventstore
  module Api
    class Connection
      APP_JSON = 'application/json'.freeze

      def initialize(endpoint)
        @endpoint = endpoint
      end

      def call
        Faraday.new(
            url: endpoint.url,
            headers: {
                accept: APP_JSON,
                content_type: APP_JSON
            }
        ) do |builder|
          builder.request :retry, max: 4, interval: 0.05,
                           interval_randomness: 0.5, backoff_factor: 2
          builder.adapter Faraday.default_adapter
          builder.response :json, content_type: APP_JSON
          builder.response :mashify
          builder.use ErrorsHandler
        end
      end

      private
      attr_reader :endpoint
    end
  end
end
