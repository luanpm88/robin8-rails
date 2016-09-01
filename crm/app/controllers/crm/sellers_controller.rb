module Crm
  class SellersController < Crm::ApplicationController
    before_action :authenticate!

    def account
      @seller = current_seller
      render json: { user: @seller, error: 0 }
    end
  end
end
