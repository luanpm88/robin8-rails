class TmpKolContact < ActiveRecord::Base
  scope :order_by_exist, ->{ order('exist desc, influence_score desc, convert(name using gb2312) asc')}
  scope :joined, -> {where(:exist => true)}
  scope :unjoined, -> {where(:exist => false)}

  def self.add_contacts(kol_uuid,contacts)
    contacts = contacts.uniq{|t| t['mobile']}
    TmpKolContact.where(:kol_uuid => kol_uuid).delete_all
    TmpKolContact.transaction do
      contacts.each do |contact|
        next if  contact['mobile'].blank?  || contact['name'].blank?   || Influence::Util.is_mobile?(contact['mobile'].to_s).blank?
        tmp_contact = TmpKolContact.new(:kol_uuid => kol_uuid, :mobile => contact['mobile'], :name => contact["name"])
        tmp_contact.save!(:validate => false)
      end
    end
  end

  def self.update_joined_kols(kol_uuid)
    mobiles = TmpKolContact.where(:kol_uuid => kol_uuid).collect{|t| t.mobile }
    joined_kols = Kol.where(:mobile_number => mobiles).all
    joined_kol_mobiles = joined_kols.collect{|t| t.mobile_number}
    TmpKolContact.where(:kol_uuid => kol_uuid, :mobile => joined_kol_mobiles).each do |contact|
      contact_kol = joined_kols.select{|t| t.mobile_number == contact.mobile}.first    rescue nil
      next if contact_kol.blank?
      contact.influence_score =  contact_kol.influence_score    rescue 0
      contact.exist = true
      contact.save
    end
  end

  def self.record_send_invite(kol_uuid,  mobile, kol = nil)
    kol_contact = KolContact.where(:kol_id => kol.id, :mobile => mobile).first      rescue nil
    if kol_contact
      kol_contact.invite_status = true
      kol_contact.invite_at = Time.now
      kol_contact.save
    end
    tmp_kol_contact = TmpKolContact.where(:kol_uuid => kol_uuid, :mobile => mobile).first     rescue nil
    if  tmp_kol_contact
      tmp_kol_contact.invite_status = true
      tmp_kol_contact.invite_at = Time.now
      tmp_kol_contact.save
    end
  end

end
