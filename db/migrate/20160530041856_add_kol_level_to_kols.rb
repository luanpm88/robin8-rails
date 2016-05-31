class AddKolLevelToKols < ActiveRecord::Migration
  def change
    add_column :kols, :kol_level, :string
  end
end
