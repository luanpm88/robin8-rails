class AddPhoneCityToKols < ActiveRecord::Migration
  def change
    add_column :kols, :phone_city, :string
  end
end
