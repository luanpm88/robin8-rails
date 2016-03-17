class AddColumnKolUuidToKol < ActiveRecord::Migration
  def change
    add_column :kols, :kol_uuid, :string
  end
end
