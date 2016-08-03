require 'faraday'
require 'faraday_middleware'

module HttpEventstore
  module Api
    class ErrorsHandler < Faraday::Response::Middleware

      def on_complete(env)
        code = env[:status]
        msg = [code, env[:body]].join(': ')
        case code
          when (400..499)
            raise ClientError.new(code, msg)
          when (500..599)
            raise ServerError.new(code, msg)
        end
      end
    end
  end
end
