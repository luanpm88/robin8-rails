module API
  module V1_5
    class QrCodeLogin < Grape::API

      before do
        authenticate!
      end

      desc "二维码扫码登录"
      params do
        requires :token, type: String
      end

      post '/scan_qr_code_and_login' do
        token = declared(params)[:token]
        id = current_kol.id
        $redis.set token, id
        ActionCable.server.broadcast "uuid_#{token}", result: "success", token: token, id: id
        present :error, 0
      end
    end

  end
end
