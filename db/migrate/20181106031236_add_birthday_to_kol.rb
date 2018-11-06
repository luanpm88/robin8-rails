class AddBirthdayToKol < ActiveRecord::Migration
  def change
  	add_column :kols, :birthday, :datetime
  end
end
