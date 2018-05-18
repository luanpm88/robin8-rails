class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
    	t.string :title, null: false
    	t.float :min_credit, default: 0
    	t.float :rate, null: false
    	t.datetime :start_at, null: false
    	t.datetime :end_at, null: false
    	t.boolean :state, default: true
    	t.string :description

      t.timestamps null: false
    end
  end
end
