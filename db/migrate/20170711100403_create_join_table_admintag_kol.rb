class CreateJoinTableAdmintagKol < ActiveRecord::Migration
  def change
    create_join_table :admintags, :kols do |t|
      # t.index [:admintag_id, :kol_id]
      # t.index [:kol_id, :admintag_id]
    end
  end
end
