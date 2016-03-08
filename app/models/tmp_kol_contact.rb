class TmpKolContact < ActiveRecord::Base
  scope :order_by_exist, ->{ order('exist desc')}

  def self.add_contacts(kol_uuid,contacts)
    mobiles = []
    TmpKolContact.transaction do
      contacts.each do |contact|
        mobiles <<  mobile['mobile']
        TmpKolContact.create(:kol_uuid => kol_uuid, :name => contact["name"], :mobile => mobile['mobile']).validate(false)
      end
    end
    # 报道存在联系人
    Influence::Influence.init_contact(self.kol_uuid)
    # 计算联系人价值
    # CalInfluenceWorker.new("contact",kol_uuid, mobiles )
    CalInfluenceWorker.perform_async("contact",kol_uuid, mobiles )
    joined_mobiles = Kol.where(:mobile_number => mobiles).collect{|t| mobile_number}
    TmpKolContact.where(:mobile => joined_mobiles).update_all(:exist => true)
  end

end
