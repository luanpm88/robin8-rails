class CreateInterestedCampaign < ActiveRecord::Migration
  def change
    create_table :interested_campaigns do |t|
      t.integer :kol_id, null: false
      t.integer :user_id, null: false
      t.integer :campaign_id, null: false
      t.string :status
      t.timestamps null: false
    end
  end
end
