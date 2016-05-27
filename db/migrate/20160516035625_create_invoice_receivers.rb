class CreateInvoiceReceivers < ActiveRecord::Migration
  def change
    create_table :invoice_receivers do |t|
      t.string :name
      t.string :phone_number
      t.string :address
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
