class CreateRechargeRecords < ActiveRecord::Migration
  def change
    create_table :recharge_records do |t|
      t.float   :credits, default: 0
      t.float   :tax, default: 0
      t.string  :receiver_name
      t.string  :receiver_type, limit: 100
      t.integer :receiver_id
      t.string  :operator
      t.string  :status, default: "pending"
      t.string  :admin_user_id
      t.boolean :need_invoice, default: false
      t.string  :remark

      t.timestamps null: false
    end

    add_index(:recharge_records, [ :receiver_type, :receiver_id ])
  end
end
