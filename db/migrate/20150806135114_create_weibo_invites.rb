class CreateWeiboInvites < ActiveRecord::Migration
  def change
    create_table :weibo_invites do |t|
      t.belongs_to :campaign, index: true
      t.belongs_to :weibo, index: true

      t.timestamps null: false
    end
    add_foreign_key :weibo_invites, :campaigns
    add_foreign_key :weibo_invites, :weibos
  end
end
