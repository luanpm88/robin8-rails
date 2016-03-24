class KolContact < ActiveRecord::Base
  scope :order_by_exist, ->{ order('exist desc, influence_score desc, name Asc')}
  scope :joined, -> {where(:exist => true)}
  scope :unjoined, -> {where(:exist => false)}

  def self.update_joined_kols(kol_id)
    mobiles = KolContact.where(:kol_id => kol_id).collect{|t| t.mobile }
    joined_kols = Kol.where(:mobile_number => mobiles)
    joined_kol_mobiles = joined_kols.collect{|t| t.mobile_number}
    KolContact.where(:kol_id => kol_id ,:mobile => joined_kol_mobiles).each do |contact|
      contact_kol = joined_kols.where(:mobile_number => contact.mobile).first    rescue nil
      contact.influence_score =  contact_kol.influence_score    rescue 0
      contact.exist = true
      contact.save
    end
  end
end
