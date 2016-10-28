class CreateCampaignEvaluations < ActiveRecord::Migration
  def change
    create_table :campaign_evaluations do |t|
      t.integer :campaign_id
      t.string :item
      t.integer :score
      t.string :content

      t.timestamps null: false
    end
  end
end
