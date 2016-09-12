class AddSomeFieldsToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :taxpayer_id, :string
    add_column :invoices, :company_address, :string
    add_column :invoices, :company_mobile,    :string
    add_column :invoices, :bank_name,    :string
    add_column :invoices, :bank_account,    :string
  end
end
