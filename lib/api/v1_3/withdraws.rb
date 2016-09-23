module API
  module V1_3
    class Withdraws < Grape::API
      resources :withdraws do
        before do
          authenticate!
        end

        params do
          requires :credits, type: Float
        end
        post 'apply' do
          return {:error => 1, :detail => '金额满100方可提现'}  if params[:credits] < 100
          return {:error => 1, :detail => '请您先绑定支付宝'}  if current_kol.alipay_account.blank?
          return {:error => 1, :detail => '当前账号有异常,请联系客服!'}  if AlipayAccountBlacklist.all.collect{|t| t.account}.include?(current_kol.alipay_account)
          if current_kol.avail_amount >= params[:credits] && params[:credits] > 0
            withdraw = Withdraw.new(:credits => params[:credits], :withdraw_type => 'alipay', :alipay_no => current_kol.alipay_account,
                                    :real_name => current_kol.alipay_name, :kol_id => current_kol.id)
            withdraw.status = 'pending'
            if withdraw.save
              present :error, 0
              present :withdraw, withdraw, with: API::V1::Entities::WithdrawEntities::Summary
            else
              present :error, 1
              error_403!({error: 1, detail: errors_message(withdraw)})
            end
          else
            return {:error => 1, :detail => '提现金额超出可用金额'}
          end
        end
      end
    end
  end
end
