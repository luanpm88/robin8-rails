class AddUserIdToCopetitors < ActiveRecord::Migration
  def change
    add_column :competitors, :user_id, :integer
  end
end
