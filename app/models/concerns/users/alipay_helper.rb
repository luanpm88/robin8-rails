module Users
  module AlipayHelper
    extend ActiveSupport::Concern
    def generate_alipay_recharge_order_for_app(credits, notify_url)
      trade_no = Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
      alipay_order =  self.alipay_orders.create({trade_no: trade_no, credits: credits, tax: 0, need_invoice: false, recharge_from: :app, status: :pending})
      params = {
        out_trade_no: alipay_order.trade_no,
        notify_url: notify_url,
        subject: "支付宝充值",
        total_fee: (ENV["total_fee"] || credits).to_f,
        body: '支付宝支付'
      }
      Alipay::Mobile::Service.mobile_securitypay_pay_string(params, :sign_type => 'RSA', :key => Rails.application.secrets[:alipay][:private_key])
    end
  end
end
