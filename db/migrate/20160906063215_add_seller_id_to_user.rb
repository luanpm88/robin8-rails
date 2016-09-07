class AddSellerIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :seller_id, :integer
    remove_column :campaigns, :seller_invite_code
  end
end
