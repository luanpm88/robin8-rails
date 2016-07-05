class AddFieldsToOauthApplications < ActiveRecord::Migration
  def change
    change_table :oauth_applications do |t|
      t.boolean :union, default: false
    end

    Doorkeeper::Application.where(union: true).first_or_create(
      name: "Robin8 Union Application",
      uid: "robin8union",
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    )

    count = 0
    error_ids = []
    User.all.each do |user|
      if user.mobile_number.present?
        condition = { mobile_number: user.mobile_number }
        dup_kol = Kol.where(email: user.email).take
      else
        condition = { email: user.email }
      end

      kol = Kol.where(condition).first_or_initialize

      kol.email = user.email if dup_kol.nil? or dup_kol == kol
      kol.encrypted_password = user.encrypted_password
      kol.name = user.name
      kol.first_name = user.first_name
      kol.last_name = user.last_name
      # kol.avatar_url = user.avatar_url
      kol.provider = "user"

      if kol.save
        user.update(kol: kol)
        count += 1
      else
        error_ids << user.id
      end
    end

    puts "Totally sync #{count} users to Kol."
    puts "But #{error_ids.size} users was failed to sync." unless error_ids.blank?
  end
end
