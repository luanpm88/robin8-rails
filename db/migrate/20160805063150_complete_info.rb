class CompleteInfo < ActiveRecord::Migration
  def change
    # Kol.joins("join identities on kols.id=identities.kol_id").where("kols.name REGEXP '^[0-9]{3}.{4}[0-9]{4}$'").each do |kol|
    #   identity = kol.identities.first      rescue nil
    #   return if identity.blank?
    #   kol.update_column(:name,identity.name)  if identity.name.present? &&  (kol.name.blank? || (kol.name.match(/^\d{3}.{4}\d{4}$/).present?))
    # end

    Kol.joins("join identities on kols.id=identities.kol_id").where("kols.avatar is null and identities.kol_id is not null").each do |kol|
      identity = kol.identities.first      rescue nil
      return if identity.blank?
      kol.update_column(:avatar_url,identity.avatar_url)
    end

  end
end
