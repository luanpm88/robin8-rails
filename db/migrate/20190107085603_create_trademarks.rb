class CreateTrademarks < ActiveRecord::Migration
  def change
    create_table :trademarks do |t|
    	t.belongs_to :user
    	
      t.string :name 
      t.text :description
      t.timestamps null: false
    end
  end
end
