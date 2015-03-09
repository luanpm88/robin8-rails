class AddIndexOnContactColumns < ActiveRecord::Migration
  def change
    add_index :contacts, [:author_id, :origin]
    add_index :contacts, [:twitter_screen_name, :origin]
    add_index :contacts, [:email, :origin]
  end
end
