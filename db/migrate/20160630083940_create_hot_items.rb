class CreateHotItems < ActiveRecord::Migration
  def change
    create_table :hot_items do |t|
      t.string :title
      t.string :origin_url
      # t.string :short_url
      t.datetime :publish_at

      t.timestamps null: false
    end
  end
end
