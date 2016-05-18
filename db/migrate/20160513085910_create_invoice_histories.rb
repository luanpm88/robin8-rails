class CreateInvoiceHistories < ActiveRecord::Migration
  def change
    create_table :invoice_histories do |t|
      t.string :name
      t.string :phone_number
      t.string :credits
      t.string :invoice_type
      t.string :title
      t.string :address
      t.string :status, default: "pending"
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
