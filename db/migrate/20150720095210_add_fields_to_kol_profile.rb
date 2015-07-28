class AddFieldsToKolProfile < ActiveRecord::Migration
  def change
    add_column :kols, :date_of_birthday, :date
    add_column :kols, :title, :string
    add_column :kols, :industry, :string
  end
end
