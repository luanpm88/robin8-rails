class TmpKolContact < ActiveRecord::Base
  scope :order_by_exist, ->{ order('exist desc')}
  scope :joined, -> {where(:exist => true)}
  scope :unjoined, -> {where(:exist => false)}

  def self.add_contacts(kol_uuid,contacts)
    mobiles = []
    TmpKolContact.transaction do
      contacts.each do |contact|
        mobiles <<  contact['mobile']
        TmpKolContact.create(:kol_uuid => kol_uuid, :name => contact["name"], :mobile => contact['mobile']).validate(false)
      end
    end
    # 报道存在联系人
    Influence::Value.init_contact(self.kol_uuid)
    # 计算联系人价值
    # CalInfluenceWorker.new("contact",kol_uuid, mobiles )
    CalInfluenceWorker.perform_async("contact",kol_uuid, mobiles )
    joined_mobiles = Kol.where(:mobile_number => mobiles).collect{|t| mobile_number}
    TmpKolContact.where(:mobile => joined_mobiles).update_all(:exist => true)
  end

end
