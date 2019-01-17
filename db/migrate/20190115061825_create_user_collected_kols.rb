class CreateUserCollectedKols < ActiveRecord::Migration
  def change
    create_table :user_collected_kols do |t|
      t.belongs_to :user
      t.belongs_to :kol
      t.string :from_by, default: 'select'
      t.string :plateform_name
      t.string :plateform_uuid
      t.string :name
      t.string :avatar_url
      t.string :desc
      t.string :remark
      t.timestamps null: false
    end
  end
end
