class WechatThirdController < ApplicationController
  $webchat_logger = Logger.new("#{Rails.root}/log/webchat.log")
  skip_before_filter :verify_authenticity_token, :only => [:notify]
  before_filter :valid_msg_signature, :only => [:notify, :callback]

  # 微信服务器发送给服务自身的事件推送（如取消授权通知，Ticket推送等）。
  # 这种系统事件推送通知（现在包括推送component_verify_ticket协议和推送取消授权通知），
  # 服务开发者收到后也需进行解密，接收到后只需直接返回字符串“success”
  def notify
    if @decrypt_msg
      # ticket 事件
      if @decrypt_msg["InfoType"] == "component_verify_ticket"
        ticket = @decrypt_msg['ComponentVerifyTicket']
        $webchat_logger.info("-------component_verify_ticket---#{ticket}")
        Rails.cache.write(WxThird::Util.component_verify_ticket_key(WxThird::Util::AppId), ticket)
      end
    end
    render :text => "success"
  end

  def callback
    $webchat_logger.info("--------callback- 公众号消息与事件 --")
    # deal_msg(params["appid"],@decryptMsg)
    render :text => "success"
  end

  private
  def valid_msg_signature
    begin
      $webchat_logger.info("\n\n\n--------params - #{params} --")
      timestamp = params["timestamp"]
      nonce = params["nonce"]
      msg_signature = params["msg_signature"]
      xml = MultiXml.parse(request.raw_post)["xml"]   rescue {}
      $webchat_logger.info("--------xml - #{xml.inspect} --")
      @encrypt_msg = xml["Encrypt"]
      @request_app_id = xml["AppId"]
      sort_params = [WxThird::Util::DescryToken, timestamp, nonce, @encrypt_msg].sort.join
      current_signature = Digest::SHA1.hexdigest(sort_params)
      $webchat_logger.info("--------params[xml] - #{current_signature == msg_signature} --")

      if  current_signature == msg_signature
        # 解密数据 秘钥
        aes_key = Base64.decode64("#{WxThird::Util::AesKey}=")
        content = QyWechat::Prpcrypt.decrypt(aes_key, @encrypt_msg, WxThird::Util::AppId)[0]
        @decrypt_msg = MultiXml.parse(content)["xml"]       rescue {}
        $webchat_logger.info("-------@decrypt_msg---#{@decrypt_msg}")
        # 解密后的数据
        return true
      else
        return render :json => {:text => "error", :msg => "消息签名校验失败" }
      end
    rescue
      return true
    end
  end

  # 处理消息
  def deal_msg(appid, msg)
    event_type = msg["MsgType"]
    if event_type == "event"
      WxEvent.deal_event_msg(appid,msg)
    elsif event_type == "text"
      WxMessage.deal_text_msg(appid,msg)
    end
  end

end
