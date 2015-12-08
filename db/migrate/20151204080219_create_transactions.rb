class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.belongs_to :account, :polymorphic => true
      t.belongs_to :item, :polymorphic => true
      t.string :direct
      t.string :subject
      t.decimal :credits, :precision => 8, :scale => 2
      t.decimal :amount, :precision => 8, :scale => 2
      t.decimal :avail_amount, :precision => 8, :scale => 2
      t.decimal :frozen_amount, :precision => 8, :scale => 2
      t.belongs_to :opposite, :polymorphic => true

      t.timestamps null: false
    end
  end
end
