class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_from_token!

  def authenticate_from_token!
    can_authenticate? || authenticate_error
  end

  private

    def can_authenticate?
      authenticate_with_http_token do |token, options|
        return true if Devise.secure_compare(ENV['access_token'], token)
        return false
      end
    end

    def authenticate_error
      render json: { error: "You can't access." }, status: 401
    end
end
