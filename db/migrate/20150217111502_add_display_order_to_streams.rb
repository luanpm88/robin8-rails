class AddDisplayOrderToStreams < ActiveRecord::Migration
  def change
    add_column :streams, :position, :integer, after: :sort_column
  end
end
