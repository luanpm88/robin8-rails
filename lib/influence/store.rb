module Influence
  class Store
    #kol_uuid => {:identities => [], :contacts => [], :identities_score => 0, :contacts_score => 0}
    def self.init_kol_influence(kol_uuid)
      kol_influence = {:identities => [], :contacts => [], :identities_score => [], :contacts_score => []}
      Rails.cache.write(kol_uuid, kol_influence, :expires_in =>  2.hours)
      kol_influence
    end


    def self.get_identities(kol_uuid)
      kol_influence = Rails.cache.read(kol_uuid)
      if !kol_influence
        kol_influence = init_kol_influence(kol_uuid)
      end
      kol_influence[:identities]
    end

    def self.get_contacts(kol_uuid)
      kol_influence = Rails.cache.read(kol_uuid)
      if !kol_influence
        kol_influence = init_kol_influence(kol_uuid)
      end
      kol_influence[:contacts]
    end

    def self.find_identity(kol_uuid, identity_uid)
      identities = get_identities(kol_uuid)
      identities = identities.select{|t| t.uid == identity_uid}
      identities[0]   rescue nil
    end

    def self.add_identity(kol_uuid, identity)
      kol_influence = Rails.cache.read(kol_uuid)
      identities = get_identities(kol_uuid)  << identity
      kol_influence[:identities] = identities
      Rails.cache.write(kol_uuid, kol_influence, :expires_in =>  2.hours)
      kol_influence[:identities]
    end

    def self.delete_identity(kol_uuid, identity_uid)
      kol_influence = Rails.cache.read(kol_uuid)
      identities = kol_influence[:identities]
      identities.delete_if{|t| t.uid == identity_uid}
      kol_influence[:identities] =  identities
      Rails.cache.write(kol_uuid, kol_influence, :expires_in =>  2.hours)
      identities
    end

    def self.add_contacts(kol_uuid, contacts)
      kol_influence = Rails.cache.read(kol_uuid)
      kol_influence[:contacts] = contacts
      Rails.cache.write(kol_uuid, kol_influence, :expires_in =>  2.hours)
      kol_influence[:contacts]
    end
  end
end
