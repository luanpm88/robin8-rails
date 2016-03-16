class TmpKolContact < ActiveRecord::Base
  scope :order_by_exist, ->{ order('exist desc, influence_score desc')}
  scope :joined, -> {where(:exist => true)}
  scope :unjoined, -> {where(:exist => false)}

  def self.add_contacts(kol_uuid,contacts)
    TmpKolContact.where(:kol_uuid => kol_uuid).delete_all
    mobiles = []
    TmpKolContact.transaction do
      contacts.each do |contact|
        mobiles <<  contact['mobile']   if contact['mobile']
        TmpKolContact.create(:kol_uuid => kol_uuid, :name => contact["name"], :mobile => contact['mobile']).validate(false)
      end
    end
    joined_kols = Kol.where(:mobile_number => mobiles).all
    joined_kol_mobiles = joined_kols.collect{|t| t.mobile_number}
    TmpKolContact.where(:mobile => joined_kol_mobiles).each do |contact|
      contact_kol = joined_kols.where(:mobile_number => contact.mobile).first    rescue nil
      contact.influence_score =  contact_kol.influence_score    rescue 0
      contact.exist = true
      contact.save
    end
    # 报道存在联系人
    Influence::Contact.init_contact(kol_uuid)
    # 计算联系人价值
    if Rails.env.development?
      # CalInfluenceWorker.new.perform("contact",kol_uuid, mobiles )
      CalInfluenceWorker.perform_async("contact",kol_uuid, mobiles )
    else
      CalInfluenceWorker.perform_async("contact",kol_uuid, mobiles )
    end
  end

end
