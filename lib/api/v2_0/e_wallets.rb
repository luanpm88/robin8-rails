# encoding: utf-8
require 'rest-client'
module API
  module V2_0
    class EWallets < Grape::API
    	resources :e_wallets do
        before do
          authenticate!
        end

        EWalletTransfer = "url" #TODO接口调用地址

        params do 
          requires :public_key, type: String
          requires :amount, type: Float
          requires :token, type: String
          requires :signature, type: String
        end
        post 'transaction' do
          params = {
            "public_key": public_key,
            "message":{
                "timestamp": Time.now.to_i,
                "coinid": 'PUTTEST',         
                "amount": amount,         
                "address": token,        
                "recvWindow": 5000
            }
             "signature": signature
          }
          res = RestClient.post(EWalletTransfer, params.to_json, {content_type: :json, accept: :json})
          res.code == 200 ? JSON.parse(res.body)['txid'] : ''
        end


      end
    end
  end
end