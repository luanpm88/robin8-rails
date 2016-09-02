module Crm
  class ApplicationController < ActionController::Base

    def error_403!(message)
      render json: { error: 1, message: message }
    end

    def current_seller
      @current_seller = Seller.find_by(private_token: request.headers["Authorization"])
    end

    def authenticate!
      unauthorized! unless current_seller
    end

    def unauthorized!
      render json: { error: 1, message: '401 Unauthorized', status: 401 }
    end
  end
end
