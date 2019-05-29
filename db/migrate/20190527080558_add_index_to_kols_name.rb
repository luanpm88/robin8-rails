class AddIndexToKolsName < ActiveRecord::Migration
  def change
    add_index :kols, :name, name: 'name', type: :fulltext
  end
end
