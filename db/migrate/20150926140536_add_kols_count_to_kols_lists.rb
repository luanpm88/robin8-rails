class AddKolsCountToKolsLists < ActiveRecord::Migration
  def change
  	add_column :kols_lists, :kols_count, :integer
  end
end
