module Crm
  class ApplicationController < ActionController::Base
    # skip_before_action :verify_authenticity_token

    def error_403!(message)
      render json: { error: 1, message: message }
    end

    def current_seller
      @current_seller = Seller.find_by(private_token: '123456')
    end

    def authenticate!
      unauthorized! unless current_seller
    end

    def unauthorized!
      render json: { error: 1, message: '401 Unauthorized', status: 401 }
    end
  end
end
