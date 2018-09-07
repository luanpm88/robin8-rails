class CreateEWalletTranstions < ActiveRecord::Migration
  def change
    create_table :e_wallet_transtions do |t|
      t.string :status, default: 'pending'
      t.belongs_to :resource, :polymorphic => true
      t.belongs_to :kol
      t.decimal :amount, :precision => 8, :scale => 2
      t.string :txid
      t.timestamps null: false
    end
  end
end
