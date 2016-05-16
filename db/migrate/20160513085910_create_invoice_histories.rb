class CreateInvoiceHistories < ActiveRecord::Migration
  def change
    create_table :invoice_histories do |t|
      t.string :credits
      t.string :type
      t.string :title
      t.string :address
      t.string :status
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
