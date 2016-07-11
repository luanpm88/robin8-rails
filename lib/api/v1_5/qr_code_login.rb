module API
  module V1_5
    class QrCodeLogin < Grape::API

      before do
        authenticate!
      end

      desc "二维码扫码登录"
      params do
        requires :login_token, type: String
      end

      post '/scan_qr_code_and_login' do
        login_token = declared(params)[:login_token]
        id = current_kol.id
        $redis.set token, id
        ActionCable.server.broadcast "uuid_#{token}", result: "success", token: login_token, id: id
        present :error, 0
      end
    end

  end
end
