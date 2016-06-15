module Users
  module AlipayHelper
    extend ActiveSupport::Concern
    def generate_alipay_recharge_order_for_app credits
      trade_no = Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
      @alipay_order =  current_user.alipay_orders.build({trade_no: trade_no, credits: credits, tax: tax, need_invoice: false, recharge_from: :app})

      params = {
        out_trade_no: @alipay_order.trade_no,
        notify_url: Rails.application.secrets[:alipay][:brand_recharge_notify_url],
        subject: "支付宝充值",
        total_fee: 0.01,#@alipay_order
        body: '支付宝支付'
      }
      Alipay::Mobile::Service.mobile_securitypay_pay_string(params, :sign_type => 'RSA', :key => Rails.application.secrets[:alipay][:private_key])
    end
  end
end