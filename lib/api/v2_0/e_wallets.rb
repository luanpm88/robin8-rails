# encoding: utf-8
require 'pmes'
module API
  module V2_0
    class EWallets < Grape::API
    	resources :e_wallets do
        before do
          authenticate!
        end

        params do
          requires :password, type: String, regexp: /^\d{6}$/
        end
        post 'apply_open' do
          return error_403!({error: 1, detail: '电子钱包已开通'}) unless current_kol.e_wallet_account

          result = PMES.gen_e_wallet(password)
          return error_403!({error: 1, detail: 'PMES gen_e_wallet 获取错误'}) unless result

          EWallet::Account.create(token: JSON.parse(result)['token'] , kol_id: current_kol.id) 

          present :error, 0
          present :alert, '创建成功'
        end


        get 'info' do
          result = PMES.get_e_wallet(current_kol.e_wallet_account.token)
          return error_403!({error: 1, detail: 'PMES get_e_wallet 获取错误'}) unless result

          $redis.set("#{current_kol.id}_put_account", JSON.parse(result)['PUT']['amount'])

          present :error, 0
          present :kol_put_account, $redis.get("#{current_kol.id}_put_account")
        end

        params do 
          requires :token, type: String
        end
        post 'transfers' do
          txid = PMES.transfer(current_kol.e_wallet_account.toke)
          current_kol.e_wallet_transactions.pending
        end


      end
    end
  end
end