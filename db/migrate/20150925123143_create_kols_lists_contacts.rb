class CreateKolsListsContacts < ActiveRecord::Migration
  def change
    create_table :kols_lists_contacts do |t|
      t.string :name
      t.integer :kols_list_id
      t.string :email
      t.timestamps null: false
    end
  end
end
