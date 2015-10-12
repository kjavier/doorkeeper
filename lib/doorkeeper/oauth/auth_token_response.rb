module Doorkeeper
  module OAuth
    class AuthTokenResponse
      attr_accessor :token

      def initialize(token)
        @token = token
      end

      def body
        {
          'token'       => token,
        }.reject { |_, value| value.blank? }
      end

      def status
        :ok
      end

      def headers
        { 'Cache-Control' => 'no-store',
          'Pragma' => 'no-cache',
          'Content-Type' => 'application/json; charset=utf-8' }
      end
    end
  end
end
