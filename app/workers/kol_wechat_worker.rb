class KolWechatWorker
  include Sidekiq::Worker

  def perform(wechat_auth_type, kol_id, user_info)

    if wechat_auth_type == 'self_info'
      kol_wechat = KolWechat.find_by(kol_id: kol_id, category: 'self_info')
    else
      kol_wechat = KolWechat.find_by(kol_id: kol_id, category: 'friends_info', openid: user_info['openid'])
    end

    if kol_wechat.blank?
      KolWechat.create!(kol_id:kol_id, category: wechat_auth_type, openid: user_info['openid'], nickname: user_info['nickname'],
                        sex: user_info['sex'], country: user_info['country'], province: user_info['province'], city: user_info['city'],
                        headimgurl: user_info['headimgurl'], unionid: user_info['unionid'] )
    end
  end
end
