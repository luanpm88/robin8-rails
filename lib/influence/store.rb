module Influence
  class Store
    def self.get_kol_identities(kol_uuid)
      if kol_uuid
        Rails.cache.read(kol_uuid)
      else
        kol_influence = {:sina_accounts => [], :wechat_accounts => [], :contacts => [], :sina_score => 0, :contact_score => 0}
        Rails.cache.write(kol_uuid, kol_influence, :expires_in =>  2.hours)
      end
    end
  end
  #kol_uuid => {:sina_account => [], :wechat_account => [], :contact => [], :sina_score => 0, :contact_score => 0}
end
