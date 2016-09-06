class AddColumnSearchKolIdToSocialAccounts < ActiveRecord::Migration
  def change
    add_column :social_accounts, :search_kol_id, :string
  end
end
