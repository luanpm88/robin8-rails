class CreateMediaListsContacts < ActiveRecord::Migration
  def change
    create_table :media_lists_contacts do |t|
      t.integer :media_list_id
      t.integer :contact_id

      t.timestamps null: false
    end
  end
end
