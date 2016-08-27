class CreateCpsArticleShares < ActiveRecord::Migration
  def change
    create_table :cps_article_shares do |t|
      t.integer :kol_id
      t.integer :cps_article_id
      t.integer :share_count, :limit => 0
      t.integer :read_count, :limit => 0

      t.timestamps null: false
    end

    add_index :cps_article_shares, :kol_id
    add_index :cps_article_shares, :cps_article_id
  end
end
