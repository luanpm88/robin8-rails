class CreateWechatArticlePerformances < ActiveRecord::Migration
  def change
    create_table :wechat_article_performances do |t|
      t.date :period
      t.integer :reached_peoples
      t.integer :page_views
      t.integer :read_more
      t.integer :favourite
      t.text :status
      t.text :claim_reason
      t.text :campaign_name
      t.text :company_name
      t.belongs_to :articles, index: true

      t.timestamps null: false
    end
  end
end
