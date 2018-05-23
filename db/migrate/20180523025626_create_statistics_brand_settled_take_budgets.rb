class CreateStatisticsBrandSettledTakeBudgets < ActiveRecord::Migration
  def change
    create_table :statistics_brand_settled_take_budgets do |t|
      t.string :tag
      t.integer :user_id
      t.float :total_take_budget
      t.integer :deleted
      t.datetime :created_at
      t.string :created_by
      t.datetime :updated_at
      t.string :updated_by
      t.integer :total_campaign_count

      t.timestamps null: false
    end
  end
end
