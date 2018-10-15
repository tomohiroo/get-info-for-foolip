class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user_from_token!

  respond_to :json

  def authenticate_user_from_token!
    can_authenticate? || authenticate_error
  end

  protected

    def response_bad_request
      render status: 400, json: { status: 400, message: 'Bad Request' }
    end

    def response_quota_exceeded
      render status: 429, json: { status: 429, message: 'Quota Exceeded'}
    end

    def response_not_found
      render status: 404, json: { status: 404, message: 'Not Found'}
    end

  private

    def can_authenticate?
      authenticate_with_http_token do |token, options|
        return false unless token.include?(':')
        user_id = token.split(':').first
        user = User.find user_id
        if user && Devise.secure_compare(user.access_token, token)
          sign_in user, store: false
          return true
        else
          false
        end
      end
    end

    def authenticate_error
      render json: { error: "You need to sign in or sign up before continuing." }, status: 401
    end
end
