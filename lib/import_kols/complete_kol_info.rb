module ImportKols
  class CompleteKolInfo
    #  TODO filter
    def self.start_do
      Kol.where("kol_role = 'mcn_big_v' or kol_role = 'big_v'").where("mobile_number is null").each do |kol|
          kol.social_accounts.each do |social_account|
            kol.mobile_number = 10000000000 + kol.id      if kol.kol_role == 'mcn_big_v' && kol.mobile_number.blank?
            kol.name = social_account.username            if kol.name.blank?   && social_account.username.present?
            kol.avatar_url = social_account.avatar_url    if kol.avatar_url.blank?   && social_account.avatar_url.present?
            kol.desc = social_account.brief               if (kol.desc.blank?  rescue true)
            kol.gender = social_account.gender            if kol.gender.blank?    && social_account.gender.present?
            if kol.app_city.blank?  && social_account.city.present?
              city_en = City.where("label like '%#{social_account.city[-2..-1]}%'").first.name_en   rescue nil
              kol.app_city = city_en   if city_en.present?
            end
            ## notice 当前 一个社交账号只有个分类
            kol.tags << social_account.tags[0] if social_account.tags.size > 0 && !kol.tags.include?(social_account.tags[0])
            kol.save!    rescue nil
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
          # kol.is_hot = true
          kol.save!    rescue nil
        end
      end
    end

    def self.reset_public_wechat
      kol_ids = SocialAccount.where(:provider => 'public_wechat').collect{|t| t.kol_id }
      Kol.where(:id => kol_ids).delete_all
      SocialAccount.where(:provider => 'public_wechat').delete_all
    end

    def self.complete_tags
      tags = Tag.all
      Kol.joins(:kol_tags).
         where("kols.kol_role = 'big_v'").
         group("kol_tags.kol_id").
         having("count('kols.id') < 5").each do |kol|
        kol_tag_size = kol.tags.size
        return if kol_tag_size >= 5
        kol.tags << (tags - kol.tags).sample(5 - kol_tag_size)
      end
    end

    def self.complete_last
      Kol.where("kol_role = 'big_v'").last(80).each do |kol|
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
          kol.tags << social_account.tags[0] if social_account.tags.size > 0 && !kol.tags.include?(social_account.tags[0])
          kol.save!    rescue nil
        end
      end
    end

    def self.complete_keywords
      Kol.find_by_sql("select kols.* from kols left join kol_keywords on kols.id=kol_keywords.kol_id where kol_keywords.id is null and kols.desc is not null").each do |kol|
        keywords = NlpService.get_keywords(kol.desc)  rescue []
        puts keywords
        keywords.each do |keyword|
          KolKeyword.create!(kol_id: kol.id, :keyword => keyword)
        end
      end
    end
  end
end
