class ChangeTypesForStreamsFields < ActiveRecord::Migration
  def change
    change_column :streams, :topics, :text
    change_column :streams, :keywords, :text
    change_column :streams, :blogs, :text
  end
end
