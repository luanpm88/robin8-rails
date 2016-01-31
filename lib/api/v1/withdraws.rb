module API
  module V1
    class Withdraw < Grape::API
      resources :withdraws do
        before do
          authenticate!
        end

        params do
          requires :status, type: String, values: ['whole', 'pending', 'approved' ,'rejected']
          optional :page, type: Integer
        end
        get '/' do
          withdraws = current_kol.withdraws.send(params[:status]).page(params[:page]).per_page(10)
          present :error, 0
          to_paginate(withdraws)
          present :withdraws, withdraws, with: API::V1::Entities::WithdrawEntities::Summary
        end


        params do
          requires :credits, type: Float
          requires :name, type: String
          requires :alipay_no, type: String
          optional :remark, type: String
        end
        post 'apply' do
          if current_kol.avail_amount > params[:credits] && params[:credits] > 0
            attrs = attributes_for_keys([:credits, :name, :alipay_no, :remark])
            withdraw = Withdraw.new
            withdraw.attrbutes = attrs
            withdraw.kol_id = current_kol.id
            if withdraw.save
              ContactMailWorker.new.perform withdraw.id, true
              present :error, 0
              present :withdraw, withdraw, with: API::V1::Entities::WithdrawEntities::Summary
            else
              present :error, 1
              error_403!({error: 1, detail: errors_message(withdraw)})
            end
          else
            return {:error => 1, :detail => '提现金额超出可用余额或提现金额格式不对'}
          end
        end
      end
    end
  end
end
