class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |t|
      t.integer :kol_id
      t.string :club_name


      t.timestamps null: false
    end
  end
end
