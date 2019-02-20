class AddProfileIdToWeibos < ActiveRecord::Migration
  def change
    add_column :weibo_accounts, :profile_id, :string
  end
end
