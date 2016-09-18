class CreateCampaignPushRecords < ActiveRecord::Migration
  def change
    create_table :campaign_push_records do |t|
      t.integer :campaign_id
      t.integer :kol_id
      t.string  :push_type
      t.boolean :success
      t.string  :success_reason
      t.string  :fail_reason

      t.timestamps null: false
    end
  end
end
