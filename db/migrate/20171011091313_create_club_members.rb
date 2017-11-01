class CreateClubMembers < ActiveRecord::Migration
  def change
    create_table :club_members do |t|
      t.integer :club_id
      t.integer :kol_id

      t.timestamps null: false
    end
  end
end
