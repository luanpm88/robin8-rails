class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :app_version
      t.string :app_platform
      t.string :os_version
      t.string :device_model
      t.string :content
      t.integer :kol_id

      t.timestamps null: false
    end
  end
end
