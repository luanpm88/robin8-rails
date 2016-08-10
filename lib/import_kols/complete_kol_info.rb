module ImportKols
  class CompleteKolInfo
    def self.start_do
      Kol.where(:kol_role => 'mcn_big_v').each do |kol|
        if kol.social_accounts.size == 0
          kol.delete
        else
          kol.social_accounts.each do |social_account|
            kol.mobile_number = 10000000000 + kol.id if kol.mobile_number.blank?
            kol.name = social_account.username            if kol.name.blank?   && social_account.username.present?
            kol.avatar_url = social_account.avatar_url    if kol.avatar_url.blank?   && social_account.avatar_url.present?
            kol.desc = social_account.brief               if (kol.desc.blank?  rescue true)
            kol.gender = social_account.gender            if kol.gender.blank?    && social_account.gender.present?
            if kol.app_city.blank?  && social_account.city.present?
              city_en = City.where("label like '%#{social_account.city[-2..-1]}%'").first.name_en   rescue nil
              kol.app_city = city_en   if city_en.present?
            end
            ## notice 当前 一个社交账号只有个分类
            kol.tags << social_account.tags[0] unless kol.tags.include?(social_account.tags[0])
            kol.save!    rescue nil
          end
        end
      end
    end

    def self.start_do_for_staging
      kol_ids = SocialAccount.where(:provider => 'public_wechat').collect{|t| t.kol_id }
      Kol.where(:id => kol_ids).each do |kol|
        kol.social_accounts.each do |social_account|
          kol.name = social_account.username            if kol.name.blank?   && social_account.username.present?
          kol.avatar_url = social_account.avatar_url    if kol.avatar_url.blank?   && social_account.avatar_url.present?
          kol.desc = social_account.brief               if (kol.desc.blank?  rescue true)
          kol.gender = social_account.gender            if kol.gender.blank?    && social_account.gender.present?
          if kol.app_city.blank?  && social_account.city.present?
            city_en = City.where("label like '%#{social_account.city[-2..-1]}%'").first.name_en   rescue nil
            kol.app_city = city_en   if city_en.present?
          end
          ## notice 当前 一个社交账号只有个分类
          kol.tags << social_account.tags[0] unless kol.tags.include?(social_account.tags[0])
          kol.is_hot = true
          kol.save!    rescue nil
        end
      end
    end

    def self.reset_public_wechat
      kol_ids = SocialAccount.where(:provider => 'public_wechat').collect{|t| t.kol_id }
      Kol.where(:id => kol_ids).delete_all
      SocialAccount.where(:provider => 'public_wechat').delete_all
    end

  end
end
