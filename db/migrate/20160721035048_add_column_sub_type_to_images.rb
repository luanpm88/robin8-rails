class AddColumnSubTypeToImages < ActiveRecord::Migration
  def change
    add_column :images, :sub_type, :string
  end
end
