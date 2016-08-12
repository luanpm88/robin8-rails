class CompleteInfo < ActiveRecord::Migration
  def change
    Kol.joins("join identities on kols.id=identities.kol_id").where("kols.avatar is null and identities.kol_id is not null").each do |kol|
      identity = kol.identities.first      rescue nil
      return if identity.blank?
      kol.avatar_url = identity.avatar_url
      kol.name = identity.name if identity.name.present? &&  (kol.name.blank? || (kol.name.match(/^\d{3}.{4}\d{4}$/).present?))
      kol.save!
    end
  end
end
