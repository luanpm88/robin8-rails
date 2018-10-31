# encoding: utf-8
require 'rest-client'
module API
  module V2_0
    class EWallets < Grape::API
    	resources :e_wallets do
        before do
          authenticate!
        end

        get 'unpaid' do
          present :error,  0
          present :amount, current_kol.e_wallet_transtions.unpaid.map(&:amount).sum.to_f
        end

        params do
          requires :page,     type: Integer
          requires :per_page, type: Integer
        end
        get 'unpaid_list' do
          trs = current_kol.e_wallet_transtions.unpaid.order('created_at DESC').page(params[:page]).per_page(params[:per_page])

          present :error, 0
          present :list,  trs.map(&:to_hash)
        end
      end
    end
  end
end