class AddColumnIdCardToKols < ActiveRecord::Migration
  def change
    add_column :kols, :id_card, :string
  end
end
