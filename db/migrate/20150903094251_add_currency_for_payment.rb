class AddCurrencyForPayment < ActiveRecord::Migration
  def change
    add_column :payments, :currency, :char
  end
end
