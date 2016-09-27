class UpdateCampaignPushRecord < ActiveRecord::Migration
  def change
    drop_table :campaign_push_records
    create_table :campaign_push_records do |t|
      t.integer :campaign_id
      t.text :kol_ids, :limit => 10000000
      t.string :push_type     # normal, append, push_all
      t.string :filter_type    # match,unmatch
      t.string :filter_reason # three_times,

      t.timestamps null: false
    end
  end
end
