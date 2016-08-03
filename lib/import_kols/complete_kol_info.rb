module ImportKols
  class CompleteKolInfo
    def self.start_do
      Kol.where(:kol_role => 'mcn_big_v').each do |kol|
        if kol.social_accounts.size == 0
          kol.delete
        else
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
            kol.professions << social_account.professions unless kol.professions.include?(social_account.professions[0])
            kol.save!    rescue nil
          end
        end
      end
    end

  end
end
