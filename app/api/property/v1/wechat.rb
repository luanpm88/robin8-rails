module Property
  module V1
    class Wechat < Base

      resource :wechat do
        params do
          requires :api_token, type: String
        end
        get '/auth_token' do
          api_token_password = 'no-country-for-old-man'

          if params[:api_token] == api_token_password
            $weixin_client ||= WeixinAuthorize::Client.new(Rails.application.secrets.wechat[:app_id],
                                                           Rails.application.secrets.wechat[:app_secret])
            encoding_password = 'IFU%DbfHsdJVu6ytv#ueiervq'
            access_token = $weixin_client.access_token
            expired_at = $weixin_client.expired_at
            time_now = DateTime.now.to_i

            cipher = Gibberish::AES.new(encoding_password)
            encrypted_access_token = cipher.encrypt(access_token)

            # un-encrypted version of access token
            # present :access_token, access_token

            present :encrypted_access_token, encrypted_access_token
            present :expired_at, expired_at
            present :expired_at_date, Time.at(expired_at).strftime('%Y-%m-%d %H:%M:%s')
            present :time_now, time_now
          else
            present :error, 1
          end

        end
      end
    end
  end
end


# DECODE USING JAVASCRIPT

# First isntall node package:
# npm install sjcl
#
# Then use following code: (where encrypted_access_token is stringified json received from API)
# var sjcl = require('sjcl')
# encrypted_access_token = "{\"v\":1,\"adata\":\"\",\"ks\":256,\"ct\":\"HznzYx4yqIBRSnot/xFj+zTOVIuAvp5sloGjqHWGjCiVZTU5WbjTExtX2e6SyozfsZhEBRqr570o2hLemFO2Mv3DKdNquyPHE4RZybSjcpOZ7eOSFnhaYvrt73mEU04W8Yw2slte5krQxWHmwz2hk0PAaQYi+yacr1keGDqt0aWrKThPxfA5Avuv+Z+9hC9q72I/AAoO\",\"ts\":96,\"mode\":\"gcm\",\"cipher\":\"aes\",\"iter\":100000,\"iv\":\"N2XHoqBRcJofDE8V\",\"salt\":\"Ue0N0rgkCQQ=\"}"
# var password = "your-super-secret-password"
# decoded = sjcl.decrypt(password, encrypted_access_token)
# console.log(decoded)
