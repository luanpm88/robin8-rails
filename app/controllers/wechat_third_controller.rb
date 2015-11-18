class WechatThirdController < ApplicationController
  $webchat_logger = Logger.new("#{Rails.root}/log/webchat.log")
  skip_before_filter :verify_authenticity_token, :only => [:notify]
  # before_filter :valid_msg_signature, :only => :notify

  # 微信服务器发送给服务自身的事件推送（如取消授权通知，Ticket推送等）。
  # 此时，消息XML体中没有ToUserName字段，而是AppId字段，
  # 即公众号服务的AppId。
  # 这种系统事件推送通知（现在包括推送component_verify_ticket协议和推送取消授权通知），
  # 服务开发者收到后也需进行解密，接收到后只需直接返回字符串“success”
  # Started POST "/wechat_third/notify?signature=fe42caa8d6fe8545952c1b6a3a927362ecf59f56&timestamp=1447771262&nonce=301792237&encrypt_type=aes&msg_signature=0dd7b2702411636af320e3b866629141cbcfbd57"
  def notify
    Rails.logger.error("------notify---#{params}----")
    Rails.logger.error("------notify---request #{request.inspect}- ---")       rescue nil
    Rails.logger.error("-----request body --- #{request.body}")                rescue nil
    $webchat_logger.info("--------notify-授权事件--")
    $webchat_logger.info("======notify ===#{params} === #{params['xml']}")
    wxXMLParams = params["xml"]
    nowAppId = wxXMLParams["AppId"]    rescue ""
    # 防止 ticket窜改
    return render :text => "success" if nowAppId != WxThird::Util::AppId
    # 加密过的数据
    xmlEncrpyPost = wxXMLParams["Encrypt"]
    # 解密数据
    aes_key = Base64.decode64("#{WxThird::Util::AesKey}=")
    content = QyWechat::Prpcrypt.decrypt(aes_key, xmlEncrpyPost, WxThird::Util::AppId)[0]
    # 解密后的数据
    decryptMsg = MultiXml.parse(content)["xml"]
    if decryptMsg
      nowAppId = decryptMsg["AppId"]
      # ticket 事件
      if decryptMsg["InfoType"] == "component_verify_ticket"
        $webchat_logger.info("-------component_verify_ticket---#{decryptMsg["ComponentVerifyTicket"]}")
        Rails.cache.write(WxThird::Util.component_verify_ticket_key(nowAppId), decryptMsg["ComponentVerifyTicket"])
      end
      # 最终返回成功就行
      render :text => "success"
    else
      render :text => "success"
    end
  end

  def callback
    $webchat_logger.info("--------callback- 公众号消息与事件 --")
    render :text => "success"
  end

  private
  # before_skip 过滤器  只针对 ticket 取消授权等事件
  def valid_msg_signature
    Rails.logger.info("------valid_msg_signature---#{params}")
    timestamp = params["timestamp"]
    nonce = params["nonce"]
    encrypt_msg = params["xml"]["Encrypt"]   rescue ""
    msg_signature = params["msg_signature"]
    sort_params = [WxThird::Util::AesKey, timestamp, nonce, encrypt_msg].sort.join
    current_signature = Digest::SHA1.hexdigest(sort_params)
    $webchat_logger.info("--------params[xml] - #{params['xml']} --")
    $webchat_logger.info("--------valid_msg_signature - #{current_signature == msg_signature} --")
    return true

    if current_signature == msg_signature
      return true
    else
      return false
    end
  end

end
