class TmpKolContact < ActiveRecord::Base
  def self.add_contacts(kol_uuid,contacts)
    mobiles = []
    TmpKolContact.transaction do
      contacts.each do |contact|
        contact["mobiles"].each do |mobile|
          mobiles <<  mobile
          TmpKolContact.create(:kol_uuid => kol_uuid, :name => contact["name"], :mobile => mobile).validate(false)
        end
      end
    end
    # 报道存在联系人
    Influence::Influence.init_contact(self.kol_uuid)
    # 计算联系人价值
    # CalInfluenceWorker.new("contact",kol_uuid, mobiles )
    CalInfluenceWorker.perform_async("contact",kol_uuid, mobiles )
  end

end
