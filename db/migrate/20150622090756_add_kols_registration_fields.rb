class AddKolsRegistrationFields < ActiveRecord::Migration
  def change
    add_column :kols, :first_name, :string
    add_column :kols, :last_name, :string
    add_column :kols, :location, :string
    add_column :kols, :interests, :string
    add_column :kols, :bank_account, :string
  end
end
