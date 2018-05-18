class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
    	t.string  :_method, 		null: false
    	t.integer :score,  			default: 0
    	t.integer :amount, 			default: 0
    	t.string  :owner_type, 	null: false
    	t.integer :owner_id, 		null: false
    	t.string  :resource_type
    	t.integer :resource_id
    	t.string 	:remark

      t.timestamps null: false
    end
  end
end
