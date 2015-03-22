require 'faraday'

module HttpEventstore
  class ErrorsHandler < Faraday::Response::Middleware

    def on_complete(env)
      code = env[:status]
      case code
        when (400..499)
          raise ClientError.new(code)
        when (500..599)
          raise ServerError.new(code)
      end
    end
  end
end
