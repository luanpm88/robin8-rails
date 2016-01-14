FactoryGirl.define do
  factory :identity do
    # kol
    # provider 'weibo'
    # uid 'uid'
    # token 'token'
    # name 'identity'

    kol
    token 'token'

    factory :weibo_identity do
      provider 'weibo'
      uid '1028013932'
    end

    factory :wechat_third_identity do
      provider 'wechat_third'
      # for Identity model attributes `alias` conflict with factory method
      self.alias 'qyx5miao'
      name '5秒轻游戏'
    end
  end
end
