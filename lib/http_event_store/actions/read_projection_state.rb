module HttpEventStore
  module Actions
    class ReadProjectionState

      def initialize(client)
        @client = client
      end

      def call(projection_name)
        response = get_projection_state(projection_name)
        return_state(response)
      rescue ClientError => e
        raise StreamAlreadyDeleted if e.code == 410
        raise StreamNotFound if e.code == 404
      end

      private
      attr_reader :client

      def get_projection_state(projection_name)
        client.read_projection_page("/projection/#{projection_name}/state")
      end

      def return_state(state)
        Helpers::ParseState.new.(state)
      end
    end
  end
end
