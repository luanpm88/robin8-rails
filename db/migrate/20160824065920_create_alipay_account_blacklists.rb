class CreateAlipayAccountBlacklists < ActiveRecord::Migration
  def change
    create_table :alipay_account_blacklists do |t|
      t.string :account

      t.timestamps null: false
    end
  end
end
