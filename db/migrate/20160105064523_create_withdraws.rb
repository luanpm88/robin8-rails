class CreateWithdraws < ActiveRecord::Migration
  def change
    create_table :withdraws do |t|
      t.integer :kol_id
      t.string :real_name
      t.integer :credits
      t.string :withdraw_type
      t.string :alipay_no
      t.string :bank_name
      t.string :bank_no
      t.string :status, :default => 'pending'
      t.string :remark

      t.timestamps null: false
    end
  end
end
