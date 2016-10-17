class KolWechatWorker
  include Sidekiq::Worker

  def perform(wechat_auth_type, kol_id, user_info)

    if wechat_auth_type == 'self_info'
      kol_wechat = KolWechat.find_by(kol_id: kol_id, category: 'self_info')
    else
      kol_wechat = KolWechat.find_by(kol_id: kol_id, category: 'friends_info', openid: user_info['openid'])
    end
  end
end
