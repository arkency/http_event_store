module HttpEventstore
  class Connection
    APP_JSON = 'application/json'.freeze

    def call
      Faraday.new(
          url: HttpEventstore.configuration.get_store_url,
          headers: {
              accept: APP_JSON,
              content_type: APP_JSON
          }
      ) do |builder|
        builder.adapter Faraday.default_adapter
        builder.response :json, content_type: 'application/json'
        builder.response :mashify
      end
    end
  end
end
