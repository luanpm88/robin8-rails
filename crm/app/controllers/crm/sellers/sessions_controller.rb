module Crm
  module Seller
    class SessionsController < Crm::ApplicationController
      def create
         seller = Seller.find_by(mobile_number: params[:mobile_number])
         if seller && seller.authenticate(params[:password])
           render json: seller, error: 0
         else
           render error_403!('用户名或密码错误')
        end
      end
    end
  end
end
