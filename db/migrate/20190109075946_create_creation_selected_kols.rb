class CreateCreationSelectedKols < ActiveRecord::Migration
  def change
    create_table :creation_selected_kols do |t|
      t.belongs_to :creation
      t.belongs_to :kol
      t.string :platefrom_name
      t.string :platefrom_uuid
      t.string :name
      t.string :avatar_url
      t.string :desc
      t.string :remark
      t.boolean :quoted, default: false
      t.timestamps null: false
    end
  end
end
