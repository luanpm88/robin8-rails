class AddTttrToTranstion < ActiveRecord::Migration
  def change
  	add_column :e_wallet_transtions, :direct, :string, default: 'income'
  end
end
