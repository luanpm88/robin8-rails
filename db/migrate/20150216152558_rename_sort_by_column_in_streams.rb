class RenameSortByColumnInStreams < ActiveRecord::Migration
  def change
    rename_column :streams, :sort_by, :sort_column
  end
end
