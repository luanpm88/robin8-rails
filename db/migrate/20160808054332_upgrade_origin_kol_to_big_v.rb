class UpgradeOriginKolToBigV < ActiveRecord::Migration
  def change
    Kol.where("name is not null and gender != 0 and app_city is not null and weixin_friend_count is not null and avatar is not null").includes(:tags).each do |kol|
      next if kol.tags.size == 0
      kol.kol_role = 'big_v'
      kol.role_check_remark = 'background_auto'
      kol.identities.each do |identity|
        if identity.provider == 'wechat'
          kol.social_accounts.build(provider: 'wechat', avatar_url: identity.avatar_url, followers_count: kol.weixin_friend_count  )
        elsif identity.provider == 'weibo'
          kol.social_accounts.build(provider: 'weibo', :homepage => "http://weibo.com/u/#{identity.uid}" )
        end
      end
      kol.save
    end
  end
end
