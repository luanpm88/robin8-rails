class CreateCampaignTargets < ActiveRecord::Migration
  def change
    create_table :campaign_targets do |t|
      t.integer     :campaign_id
      t.string      :target_type   # 0, 1, 2
      t.string      :age
      t.string      :province
      t.string      :city
      t.string      :sex   # all, male, female
      t.timestamps  null: false      
    end
  end
end
