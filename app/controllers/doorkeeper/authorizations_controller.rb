module Doorkeeper
  class AuthorizationsController < Doorkeeper::ApplicationController
    before_filter :authenticate_resource_owner!

    def new
      if pre_auth.authorizable?
        if skip_authorization? || matching_token?
          auth = authorization.authorize

          if params[:response_type] == 'json'
            auth_token_response = OAuth::AuthTokenResponse.new(auth.redirect_uri[:code])
            response.headers.merge!(auth_token_response.headers)
            render json: auth_token_response.body, status: auth_token_response.status
          else
            redirect_to auth.redirect_uri
          end
        else
          render :new
        end
      else
        if params[:response_type] == 'json'
          error_response = OAuth::ErrorResponse.new(name: 'invalid_client')
          response.headers.merge!(error_response.headers)
          render json: error_response.body, status: error_response.status
        else
          render :error
        end
      end
    end

    # TODO: Handle raise invalid authorization
    def create
      redirect_or_render authorization.authorize
    end

    def destroy
      redirect_or_render authorization.deny
    end

    private

    def matching_token?
      AccessToken.matching_token_for pre_auth.client,
                                     current_resource_owner.id,
                                     pre_auth.scopes
    end

    def redirect_or_render(auth)
      if auth.redirectable?
        redirect_to auth.redirect_uri
      else
        render json: auth.body, status: auth.status
      end
    end

    def pre_auth
      @pre_auth ||= OAuth::PreAuthorization.new(Doorkeeper.configuration,
                                                server.client_via_uid,
                                                params)
    end

    def authorization
      @authorization ||= strategy.request
    end

    def strategy
      @strategy ||= server.authorization_request pre_auth.response_type
    end
  end
end
