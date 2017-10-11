class CreateJoinTableClubKol < ActiveRecord::Migration
  def change
    create_join_table :clubs, :kols do |t|
      # t.index [:club_id, :kol_id]
      # t.index [:kol_id, :club_id]
    end
  end
end
