class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
    	t.integer :tender_id, null: false
    	t.string  :date_show, null: false

    	t.belongs_to :kol

      t.timestamps null: false
    end
  end
end
