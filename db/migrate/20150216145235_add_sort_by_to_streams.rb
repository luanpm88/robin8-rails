class AddSortByToStreams < ActiveRecord::Migration
  def change
    add_column :streams, :sort_by, :string, after: :sources
  end
end
