class CreateFollowships < ActiveRecord::Migration
  def change
    create_table :followships do |t|
      t.belongs_to :follower
      t.belongs_to :kol

      t.timestamps null: false
    end
    add_index :followships, :follower_id
    add_index :followships, :kol_id
  end
end
