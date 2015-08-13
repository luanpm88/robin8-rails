class AddMobileNumberForKol < ActiveRecord::Migration
  def change
    add_column :kols, :mobile_number, :string
  end
end
