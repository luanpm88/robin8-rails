class AddOutletToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :outlet, :string
  end
end
