class CallbackGeometryWorker
  include Sidekiq::Worker

  def perform(kol_id)
    kol              = Kol.find(kol_id)
    url              = "http://callback.onemorething.net.cn/robin8/newreg"
    data             = {cell: kol.mobile_number, regtime: kol.created_at.strftime("%F %T")}.to_json
    public_key       = OpenSSL::PKey::RSA.new(Rails.application.secrets[:geometry][:public_key])
    encrypted_string = Base64.encode64(public_key.public_encrypt(data, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING))

    HTTParty.post(url, {body: {data: encrypted_string}})
  end
end
