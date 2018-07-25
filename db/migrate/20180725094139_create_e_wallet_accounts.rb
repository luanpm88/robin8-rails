class CreateEWalletAccounts < ActiveRecord::Migration
  def change
    create_table :e_wallet_accounts do |t|
    	t.string :token, null: false

    	t.references :kol, null: false

      t.timestamps null: false
    end
  end
end
