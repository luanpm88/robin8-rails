class TmpKolContact < ActiveRecord::Base
  scope :order_by_exist, ->{ order('exist desc, influence_score desc')}
  scope :joined, -> {where(:exist => true)}
  scope :unjoined, -> {where(:exist => false)}

  def self.add_contacts(kol_uuid,contacts)
    tmp_kol_contacts = TmpKolContact.where(:kol_uuid => kol_uuid)
    TmpKolContact.transaction do
      contacts.each do |contact|
        tmp_contact =  tmp_kol_contacts.find_by(:mobile => contact['mobile'])
        tmp_contact = TmpKolContact.new(:kol_uuid => kol_uuid, :mobile => contact['mobile'])  if tmp_contact.blank?
        tmp_contact.name =  contact["name"]
        tmp_contact.save(:validate => false)
      end
    end
    mobiles = TmpKolContact.where(:kol_uuid => kol_uuid).collect{|t| t.mobile}
    update_joined_kols(kol_uuid, mobiles)
    # 报道存在联系人
    Influence::Contact.init_contact(kol_uuid)
    # 计算联系人价值
    if Rails.env.development?
      CalInfluenceWorker.new.perform("contact",kol_uuid, mobiles )
    else
      CalInfluenceWorker.perform_async("contact",kol_uuid, mobiles )
    end
  end

  def self.update_joined_kols(kol_uuid, mobiles = nil)
    mobiles ||= TmpKolContact.where(:kol_uuid => kol_uuid).collect{|t| t.mobile }
    joined_kols = Kol.where(:mobile_number => mobiles).all
    joined_kol_mobiles = joined_kols.collect{|t| t.mobile_number}
    TmpKolContact.where(:mobile => joined_kol_mobiles).each do |contact|
      contact_kol = joined_kols.where(:mobile_number => contact.mobile).first    rescue nil
      contact.influence_score =  contact_kol.influence_score    rescue 0
      contact.exist = true
      contact.save
    end
  end

  def self.record_send_invite(kol_uuid,  mobile, kol = nil)
    if kol
      kol_contact = KolContact.where(:kol_id => kol.id, :mobile => mobile).first
      kol_contact.invite_status = true
      kol_contact.invite_at = Time.now
      kol_contact.save
    end
    tmp_kol_contact = TmpKolContact.where(:kol_uuid => kol_uuid, :mobile => mobile).first
    tmp_kol_contact.invite_status = true
    tmp_kol_contact.invite_at = Time.now
    tmp_kol_contact.save
  end


end
