class CreateWeiboAccountsCircles < ActiveRecord::Migration
  def change
    create_table :weibo_accounts_circles do |t|
      t.belongs_to :weibo_account
      t.belongs_to :circle
      t.timestamps null: false
    end
  end
end
