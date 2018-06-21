class AddAttrsToKol < ActiveRecord::Migration
  def change
  	add_column :kols, :role, :string
  	add_column :kols, :admin_id, :integer
  end
end
