class CreateKolShows < ActiveRecord::Migration
  def change
    create_table :kol_shows do |t|
      t.integer :kol_id
      t.string :title
      t.string :cover_url
      t.text :desc
      t.string :link
      t.string :provider
      t.integer :like_count
      t.integer :read_count
      t.integer :repost_count
      t.integer :comment_count
      t.string :publish_time

      t.timestamps null: false
    end
  end
end
