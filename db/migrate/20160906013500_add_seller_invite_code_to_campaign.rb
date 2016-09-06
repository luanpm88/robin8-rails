class AddSellerInviteCodeToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :seller_invite_code, :string
  end
end
