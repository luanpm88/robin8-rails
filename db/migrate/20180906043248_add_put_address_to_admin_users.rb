class AddPutAddressToAdminUsers < ActiveRecord::Migration
  def change
  	add_column :admin_users, :put_address, :string
  end
end
