class CreateStatisticsCampaignSettledTakeBudgets < ActiveRecord::Migration
  def change
    create_table :statistics_campaign_settled_take_budgets do |t|
      t.integer :campaign_id
      t.string :take_budget
      t.integer :deleted
      t.datetime :created_at
      t.string :created_by
      t.datetime :updated_at
      t.string :updated_by
      t.integer :user_id
      t.string :tag

      t.timestamps null: false
    end
  end
end
