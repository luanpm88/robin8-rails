class AddColumnMobileNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_number, :string
  end
end
