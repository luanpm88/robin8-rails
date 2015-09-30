class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.text :text
      t.belongs_to :campaign, index: true
      t.belongs_to :kol, index: true

      t.timestamps null: false
    end
  end
end
