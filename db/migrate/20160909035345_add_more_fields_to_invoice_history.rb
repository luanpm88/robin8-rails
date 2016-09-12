class AddMoreFieldsToInvoiceHistory < ActiveRecord::Migration
  def change
    add_column :invoice_histories, :taxpayer_id, :string
    add_column :invoice_histories, :company_address, :string
    add_column :invoice_histories, :company_mobile, :string
    add_column :invoice_histories, :bank_name, :string
    add_column :invoice_histories, :bank_account, :string
  end
end
