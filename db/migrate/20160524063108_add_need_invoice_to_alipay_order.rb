class AddNeedInvoiceToAlipayOrder < ActiveRecord::Migration
  def change
    add_column :alipay_orders, :need_invoice, :boolean, default: false
  end
end
