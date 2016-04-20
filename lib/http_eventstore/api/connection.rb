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
        ) do |builder|
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
