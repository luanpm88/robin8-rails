class AddNameToKols < ActiveRecord::Migration
  def change
    add_column :kols, :name, :string
  end
end
