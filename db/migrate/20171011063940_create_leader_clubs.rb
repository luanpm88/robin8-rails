class CreateLeaderClubs < ActiveRecord::Migration
  def change
    create_table :leader_clubs do |t|

      t.timestamps null: false
    end
  end
end
