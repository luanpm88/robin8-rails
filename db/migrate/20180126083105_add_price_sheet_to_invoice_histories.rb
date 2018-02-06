class AddPriceSheetToInvoiceHistories < ActiveRecord::Migration
  def change
    add_column :invoice_histories, :price_sheet, :boolean , default: false
  end
end
