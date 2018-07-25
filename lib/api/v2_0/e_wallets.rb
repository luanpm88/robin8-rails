# encoding: utf-8
require "pems"
module API
  module V2_0
    class EWallets < Grape::API
    	resources :e_wallets do
        before do
          authenticate!
        end

        params do
          requires :password, type: String
        end
        post 'apply_open' do

        end

        params do 
          requires :token, type: String
        end
        get 'info' do 
        end

        params do 
          requires :token, type: String
        end
        get 'transfers_list' do
        end




      end
    end
  end
end