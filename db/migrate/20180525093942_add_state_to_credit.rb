class AddStateToCredit < ActiveRecord::Migration
  def change
  	add_column :credits, :state, :integer
  end
end
