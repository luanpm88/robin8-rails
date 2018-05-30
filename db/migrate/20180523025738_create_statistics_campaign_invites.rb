class CreateStatisticsCampaignInvites < ActiveRecord::Migration
  def change
    create_table :statistics_campaign_invites do |t|
      t.string :tag
      t.datetime :data_date
      t.integer :total_activity_count

      t.timestamps null: false
    end
  end
end
