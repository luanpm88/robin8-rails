module ImportKols
  class CompleteKolInfo
    def self.start_do
      Kol.where(:kol_role => 'mcn_big_v').each do |kol|
        kol.reload
        kol.social_accounts.each do |social_account|
          kol.name = social_account.username if kol.name.blank?
          kol.avatar_url = social_account.avatar_url    if kol.avatar_url.blank?   && social_account.avatar_url.present?
          kol.brief = social_account.brief              if kol.brief.blank?    && social_account.brief.present?
          kol.gender = social_account.gender            if kol.gender.blank?    && social_account.gender.present?
          if kol.city.blank?  && social_account.city.present?
            app_city = City.where("label like '%#{social_account.city[-2..-1]}%'").first.name_en   rescue nil
            kol.app_city = social_account.city   if app_city.present?
          end
          kol.professions << social_account.professions unless kol.professions.include?(social_account.professions)
          kol.save    rescue nil
        end
      end
    end

  end
end
