class CreateWeiboAccountsCities < ActiveRecord::Migration
  def change
    create_table :weibo_accounts_cities do |t|
      t.belongs_to :weibo_account
      t.belongs_to :city
      t.timestamps null: false
    end
  end
end
