class AddKeywordsToStreams < ActiveRecord::Migration
  def change
    add_column :streams, :keywords, :string
  end
end
