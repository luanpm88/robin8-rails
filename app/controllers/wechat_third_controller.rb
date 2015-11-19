class WechatThirdController < ApplicationController
  $webchat_logger = Logger.new("#{Rails.root}/log/webchat.log")
  skip_before_filter :verify_authenticity_token, :only => [:notify]
  before_filter :valid_msg_signature, :only => :notify

  # 微信服务器发送给服务自身的事件推送（如取消授权通知，Ticket推送等）。
  # 这种系统事件推送通知（现在包括推送component_verify_ticket协议和推送取消授权通知），
  # 服务开发者收到后也需进行解密，接收到后只需直接返回字符串“success”
  def notify
    # 解密数据
    aes_key = Base64.decode64("#{WxThird::Util::AesKey}=")
    content = QyWechat::Prpcrypt.decrypt(aes_key, @encrypt_msg, WxThird::Util::AppId)[0]
    # 解密后的数据
    decrypt_msg = MultiXml.parse(content)["xml"]
    $webchat_logger.info("--------decrypt_msg - #{decrypt_msg.inspect} --")
    if decrypt_msg
      # ticket 事件
      if decrypt_msg["InfoType"] == "component_verify_ticket"
        ticket = decrypt_msg['ComponentVerifyTicket']
        $webchat_logger.info("-------component_verify_ticket---#{ticket}")
        Rails.cache.write(WxThird::Util.component_verify_ticket_key(WxThird::Util::AppId), ticket)
      end
    end
    render :text => "success"
  end

  def callback
    $webchat_logger.info("--------callback- 公众号消息与事件 --")
    render :text => "success"
  end

  private
  # before_skip 过滤器  只针对 ticket 取消授权等事件
  def valid_msg_signature
    begin
      timestamp = params["timestamp"]
      nonce = params["nonce"]
      msg_signature = params["msg_signature"]
      xml = MultiXml.parse(request.raw_post)["xml"]   rescue {}
      $webchat_logger.info("--------xml - #{xml.inspect} --")
      @encrypt_msg = xml["Encrypt"]
      @request_app_id = xml["AppId"]
      $webchat_logger.info("-------- @encrypt_msg - #{ @encrypt_msg} ---@request_app_id-#{@request_app_id}-")
      sort_params = [WxThird::Util::DescryToken, timestamp, nonce, @encrypt_msg].sort.join
      current_signature = Digest::SHA1.hexdigest(sort_params)
      $webchat_logger.info("--------params[xml] - #{current_signature == msg_signature} --")
      return true
    rescue
      return true
    end

  end

end
