class AddPerformedAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :performed_at, :datetime
    add_index :posts, :performed_at
  end
end
