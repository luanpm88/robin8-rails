class AddColumnAccessTokenRefreshTimeToIdientity < ActiveRecord::Migration
  def change
    add_column :identities, :access_token_refresh_time, :datetime

    add_column :tmp_identities, :access_token_refresh_time, :datetime

    Identity.all.each do |identity|
      identity.update_columns(:access_token_refresh_time => identity.created_at, :refresh_time => identity.created_at)
    end

    TmpIdentity.all.each do |identity|
      identity.update_columns(:access_token_refresh_time => identity.created_at, :refresh_time => identity.created_at)
    end
  end
end
