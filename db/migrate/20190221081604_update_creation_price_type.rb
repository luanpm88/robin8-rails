class UpdateCreationPriceType < ActiveRecord::Migration
  def change
  	change_column :creations, :pre_amount, :decimal, :precision => 10, :scale => 2
   	change_column :creations, :amount, :decimal, :precision => 10, :scale => 2
   	change_column :tenders, :price, :decimal, :precision => 10, :scale => 2
  end
end
