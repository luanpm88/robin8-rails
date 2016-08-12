class UpgradeOriginKolToBigV < ActiveRecord::Migration
  def change
    Kol.where("mobile_number is not null and name is not null and gender != 0 and app_city is not null and weixin_friend_count is not null and (avatar is not null or avatar_url is not null)").includes(:tags).each do |kol|
      next if kol.tags.size == 0
      next if kol.social_accounts.size > 0
      kol.kol_role = 'big_v'
      kol.role_apply_status = 'passed'
      kol.role_check_remark = 'background_auto'
      if kol.identities.size == 0
        kol.social_accounts.build(provider: 'wechat', username: kol.name, avatar_url: kol.avatar.url , followers_count: kol.weixin_friend_count)
      elsif kol.social_accounts.size == 0
        kol.identities.each do |identity|
          if identity.provider == 'wechat'
            kol.social_accounts.build(provider: 'wechat', username: identity.name,  avatar_url: identity.avatar_url )
          elsif identity.provider == 'qq'
              kol.social_accounts.build(provider: 'qq', username: identity.name,  avatar_url: identity.avatar_url, followers_count: kol.weixin_friend_count  )
          elsif identity.provider == 'weibo'
            social_account = kol.social_accounts.build(provider: 'weibo', :homepage => "http://weibo.com/u/#{identity.uid}" )
            social_account.auto_complete_info
          end
        end
      end
      kol.save!
    end

  end
end
