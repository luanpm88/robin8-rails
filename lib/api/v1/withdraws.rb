module API
  module V1
    class Withdraw < Grape::API
      resources :withdraws do
        before do
          authenticate!
        end


        params do
          requires :status, type: String, values: ['all', 'pending', 'approved' ,'rejected']
          optional :page, type: Integer
        end
        get '/' do


        end


        params do
          requires :credits, type: Float
          optional :remark, type: String
        end
        post 'apply' do
          if current_kol.avail_amount > params[:credits] && params[:credits] > 0
          else
            return {:error => 1, :detail => '提现金额超出可用余额或提现金额格式不对'}
          end
        end
      end
    end
  end
end
