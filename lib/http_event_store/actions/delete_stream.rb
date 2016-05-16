module HttpEventstore
  module Actions
    class DeleteStream

      def initialize(client)
        @client = client
      end

      def call(stream_name, hard_delete)
        raise IncorrectStreamData if stream_name.nil? || stream_name.empty?
        delete_stream(stream_name, hard_delete)
      rescue ClientError => e
        raise StreamAlreadyDeleted
      end

      private
      attr_reader :client

      def delete_stream(stream_name, hard_delete)
        client.delete_stream(stream_name, hard_delete)
      end
    end
  end
end
