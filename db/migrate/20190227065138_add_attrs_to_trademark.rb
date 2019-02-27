class AddAttrsToTrademark < ActiveRecord::Migration
  def change
  	add_column :trademarks, :keywords, :string
  end
end
