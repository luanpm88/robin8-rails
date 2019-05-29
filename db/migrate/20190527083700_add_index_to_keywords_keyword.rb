class AddIndexToKeywordsKeyword < ActiveRecord::Migration
  def change
    add_index :kol_keywords, :keyword, name: 'keyword', type: :fulltext
  end
end
