class CreateCampaignApplies < ActiveRecord::Migration
  def change
    create_table :campaign_applies do |t|
      t.integer :campaign_id
      t.integer :kol_id
      t.string :name
      t.string :phone
      t.string :weixin_no
      t.integer :weixin_friend_count
      t.string :status

      t.string :expect_price
      t.string :agree_reason

      t.timestamps null: false
    end
  end
end
