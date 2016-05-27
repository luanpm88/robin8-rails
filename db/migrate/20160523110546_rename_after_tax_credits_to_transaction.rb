class RenameAfterTaxCreditsToTransaction < ActiveRecord::Migration
  def up
    rename_column :transactions, :after_tax_credits, :tax
    change_column :transactions, :tax, :decimal, precision: 12, scale: 2, default: 0
  end

  def down
    change_column :transactions, :tax, :string
    rename_column :transactions, :tax, :after_tax_credits
  end
end
