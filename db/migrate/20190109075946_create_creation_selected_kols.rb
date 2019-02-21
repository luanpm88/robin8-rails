class CreateCreationSelectedKols < ActiveRecord::Migration
  def change
    create_table :creation_selected_kols do |t|
      t.belongs_to :creation
      t.belongs_to :kol
      t.string :from_by, default: 'select'
      t.string :plateform_name
      t.string :plateform_uuid
      t.string :name
      t.string :avatar_url
      t.string :desc
      t.string :remark
      t.string :status, default: 'preelect'
      t.timestamps null: false
    end
  end
end
