module API
  module V1
    class Withdraws < Grape::API
      resources :withdraws do
        before do
          authenticate!
        end

        params do
          optional :status, type: String, values: ['pending', 'approved' ,'rejected']
          optional :page, type: Integer
        end
        get '/' do
          if params[:status].present?
            withdraws = current_kol.withdraws.send(params[:status]).page(params[:page]).per_page(10)
          else
            withdraws = current_kol.withdraws.page(params[:page]).per_page(10)
          end
          present :error, 0
          to_paginate(withdraws)
          present :withdraws, withdraws, with: API::V1::Entities::WithdrawEntities::Summary
        end


        params do
          requires :credits, type: Float
          requires :real_name, type: String
          requires :alipay_no, type: String
          optional :remark, type: String
        end
        post 'apply' do
          return {:error => 1, :detail => '升级APP后方可提现'}
          # return {:error => 1, :detail => '金额满100方可提现'}  if params[:credits] < 100
          # if current_kol.avail_amount > params[:credits] && params[:credits] > 0
          #   attrs = attributes_for_keys([:credits, :real_name, :alipay_no, :remark])
          #   withdraw = Withdraw.new(:withdraw_type => 'alipay')
          #   withdraw.attributes = attrs
          #   withdraw.kol_id = current_kol.id
          #   withdraw.status = 'pending'
          #   if withdraw.save
          #     # ContactMailWorker.new.perform withdraw.id, true
          #     present :error, 0
          #     present :withdraw, withdraw, with: API::V1::Entities::WithdrawEntities::Summary
          #   else
          #     present :error, 1
          #     error_403!({error: 1, detail: errors_message(withdraw)})
          #   end
          # else
          #   return {:error => 1, :detail => '提现金额超出可用金额'}
          # end
        end


        put 'update_is_read' do 
          present :error, 0
          withdraw = current_kol.withdraws.rejected.first
          withdraw.update_attributes(is_read: true) if withdraw.present?
          present :detail, "已读"
        end

      end
    end
  end
end
