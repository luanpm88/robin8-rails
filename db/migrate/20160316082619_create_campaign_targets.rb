class CreateCampaignTargets < ActiveRecord::Migration
  def change
    create_table :campaign_targets do |t|
      t.string :target_type
      t.string :target_content
      t.references :campaign, index: true

      t.timestamps null: false
    end
    add_foreign_key :campaign_targets, :campaigns
  end
end
