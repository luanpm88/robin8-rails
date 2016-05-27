class KolContact < ActiveRecord::Base
  scope :order_by_exist, ->{ order('exist desc, influence_score desc, convert(name using gb2312) asc')}
  scope :joined, -> {where(:exist => true)}
  scope :unjoined, -> {where(:exist => false)}

  def self.update_joined_kols(kol_id)
    mobiles = KolContact.where(:kol_id => kol_id).collect{|t| t.mobile }
    joined_kols = Kol.where(:mobile_number => mobiles).all
    joined_kol_mobiles = joined_kols.collect{|t| t.mobile_number}
    KolContact.where(:kol_id => kol_id ,:mobile => joined_kol_mobiles).each do |contact|
      contact_kol = joined_kols.select{|t| t.mobile_number == contact.mobile}.first    rescue nil
      next if contact_kol.blank?
      contact.influence_score =  contact_kol.influence_score    rescue 0
      contact.exist = true
      contact.save
    end
  end

  def self.add_contacts(kol_uuid,contacts, kol_id)
    contacts = contacts.uniq{|t| t['mobile']}
    present_mobiles = KolContact.where(:kol_id => kol_id).collect{|t| t.mobile.to_s }
    KolContact.transaction do
      contacts.each do |contact|
        next if  contact['mobile'].blank?  || contact['name'].blank?   || Influence::Util.is_mobile?(contact['mobile'].to_s).blank?
        next if  present_mobiles.include?(contact['mobile'].to_s)
        kol_contact = KolContact.new(:kol_uuid => kol_uuid, :kol_id => kol_id, :mobile => contact['mobile'], :name => contact["name"])
        kol_contact.save!(:validate => false)
      end
    end
  end
end
