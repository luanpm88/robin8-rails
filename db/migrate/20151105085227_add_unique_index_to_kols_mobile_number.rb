class AddUniqueIndexToKolsMobileNumber < ActiveRecord::Migration
  def change
    add_index :kols, :mobile_number, unique: true
  end
end
