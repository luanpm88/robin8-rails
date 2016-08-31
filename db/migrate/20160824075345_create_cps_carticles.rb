class CreateCpsArticles < ActiveRecord::Migration
  def change
    create_table   :cps_articles do |t|
      t.references :kol
      t.string     :title
      t.string     :cover
      t.text       :body
      t.timestamps null: false
    end
  end
end
