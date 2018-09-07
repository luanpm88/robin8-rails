require 'rest-client'

class PMES

    Host        = 'http://pmesmw.robin8.net:2046'
    NewMember   = Host + '/account/new'
    BasicInfo   = Host + '/account'
    EWalletInfo = Host + '/wallets'
    EWalletTransfer = Host + '/api/accounts/withdraw'

    def self.transaction(token, public_key, amount, signature)
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