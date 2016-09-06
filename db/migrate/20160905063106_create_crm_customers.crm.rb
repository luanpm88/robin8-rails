# This migration comes from crm (originally 20160901064020)
class CreateCrmCustomers < ActiveRecord::Migration
  def change
    create_table :crm_customers do |t|
      t.string :name
      t.string :mobile_number
      t.string :company_name
      t.text :visit_detail
      t.string :company_address
      t.decimal :lat, :precision => 10, :scale => 6
      t.decimal :lng, :precision => 10, :scale => 6
      t.integer :seller_id
      t.timestamps null: false
    end
  end
end
