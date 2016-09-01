module Crm
  class CustomersController < Crm::ApplicationController
    before_action :authenticate!

    def index
      @customers = current_seller.customers
      render json: { customers: @customers, error: 0 }
    end

    def show
      @customer = current_seller.customers.find(:id)
      render json: { customer: @customer }
    end

    def create
      @customer = current_seller.customers.build(customer_params)
      if @customer.save
        render json: { error: 0 }
      else
        render json: { error: 1, message: '创建客户失败' }
      end
    end

    def update
      @customer = current_seller.customers.find(params[:id])
      begin
        @customer.update_attributes!(customer_params)
        render json: { error: 0 }
      rescue
        render json: { error: 1, message: '更新失败' }
      end
    end

    private

    def customer_params
      params.permit(:name, :mobile_number, :company_name, :visit_detail, :company_address, :lat, :lng)
    end
  end
end
