module Crm
  class SellersController < Crm::ApplicationController
    before_action :authenticate!

    def account
      @seller = current_seller
      render json: { user: @seller, error: 0 }
    end

    def orders
      @orders = AlipayOrder.where(invite_code: current_seller.invite_code).paginate(:page => params[:page])
      render json: { orders: @orders, count: @orders.count, error: 0 }
    end
  end
end
