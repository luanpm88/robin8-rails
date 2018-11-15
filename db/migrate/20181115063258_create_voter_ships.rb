class CreateVoterShips < ActiveRecord::Migration
  def change
    create_table :voter_ships do |t|
    	t.integer :voter_id,  null: false
    	t.integer :count,     default: 0

    	t.belongs_to :kol

      t.timestamps null: false
    end
  end
end
