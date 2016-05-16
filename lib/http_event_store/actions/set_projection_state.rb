module HttpEventStore
  module Actions
    class SetProjectionState

      def initialize(client)
        @client = client
      end

      def call(projection_name, state)
        response = set_projection_state(projection_name, state)
      rescue ClientError => e

      end

      private
      attr_reader :client

      def set_projection_state(projection_name, state)
        client.set_projection_state(projection_name, state)
      end
    end
  end
end
