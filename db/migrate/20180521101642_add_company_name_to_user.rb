class AddCompanyNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :campany_name, :string
  end
end
