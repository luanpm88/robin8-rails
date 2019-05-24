class ChangeTendersPriceColumn < ActiveRecord::Migration
  def change
    change_column :tenders, :price, :decimal, :precision => 16, :scale => 2
  end
end
