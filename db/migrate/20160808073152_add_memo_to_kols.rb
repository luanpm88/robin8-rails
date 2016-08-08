class AddMemoToKols < ActiveRecord::Migration
  def change
    add_column :kols, :memo, :text
  end
end
