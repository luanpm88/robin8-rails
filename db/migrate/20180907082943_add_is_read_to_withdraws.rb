class AddIsReadToWithdraws < ActiveRecord::Migration
  def change
  	add_column :withdraws, :is_read, :boolean, default: false
  end
end
