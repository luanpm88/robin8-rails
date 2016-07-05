module Campaigns
  module AlipayHelper
    extend ActiveSupport::Concern
    def generate_alipay_campaign_order
      params = {
        out_trade_no: self.trade_number,
        notify_url: Rails.application.secrets[:alipay][:notify_url],
        subject: self.name,
        total_fee: (ENV["total_fee"] || self.need_pay_amount).to_f,
        body: '支付宝支付'
      }
      Alipay::Mobile::Service.mobile_securitypay_pay_string(params, :sign_type => 'RSA', :key => Rails.application.secrets[:alipay][:private_key])
    end
  end

  def alipay_trade_no
    begin
      self.alipay_notify_text.last.match(/trade_no=\".+?\"/).to_s.gsub("trade_no=\"", "").gsub("\"", "")
    rescue Exception => e
    end
  end

  def alipay_amount
    self.amount - self.voucher_amount
  end
end