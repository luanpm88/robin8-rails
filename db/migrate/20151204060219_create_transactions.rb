class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :account
      t.references :item
      t.string :direct
      t.string :subject
      t.decimal :credits, :precision => 8, :scale => 2
      t.decimal :amount, :precision => 8, :scale => 2
      t.decimal :avail_amount, :precision => 8, :scale => 2
      t.decimal :frozen_amount, :precision => 8, :scale => 2
      t.references :opposite

      t.timestamps null: false
    end
  end
end
