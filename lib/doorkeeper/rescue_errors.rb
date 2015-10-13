module Doorkeeper
  module RescueErrors
    def self.included(base)
      base.rescue_from Doorkeeper::Errors::InvalidProviderDetails do |e|
        error_response = Doorkeeper::OAuth::ErrorResponse.new(name: :invalid_provider_details)
        render json: error_response.body.to_json, status: error_response.status
      end
    end
  end
end
