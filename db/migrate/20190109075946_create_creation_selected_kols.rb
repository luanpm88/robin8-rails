class CreateCreationSelectedKols < ActiveRecord::Migration
  def change
    create_table :creation_selected_kols do |t|
      t.belongs_to :creation
      t.belongs_to :kol 
      t.string :resource
      t.string :remark
      t.timestamps null: false
    end
  end
end
