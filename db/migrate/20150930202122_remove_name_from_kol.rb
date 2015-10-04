class RemoveNameFromKol < ActiveRecord::Migration
  def change
    remove_column :kols, :name
  end
end
