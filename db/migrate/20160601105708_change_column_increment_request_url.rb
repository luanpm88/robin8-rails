class ChangeColumnIncrementRequestUrl < ActiveRecord::Migration
  def change
    change_column :campaign_shows, :request_url, :limit => 2000

    change_column :kol_influence_values, :kol_uuid, :limit => 50
    change_column :kol_influence_value_histories, :kol_uuid, :limit => 50
    change_column :kol_contacts, :kol_uuid, :limit => 50
    change_column :tmp_kol_contacts, :kol_uuid, :limit => 50
    add_index :kol_influence_values, :kol_uuid
    add_index :kol_influence_value_histories, :kol_uuid
    add_index :kol_contacts, :kol_uuid
    add_index :tmp_kol_contacts, :kol_uuid
  end
end
