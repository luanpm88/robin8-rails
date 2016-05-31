class CreateAnalysisIdentities < ActiveRecord::Migration
  def change
    create_table :analysis_identities do |t|
      t.integer :kol_id
      t.string :provider
      t.string :name
      t.string :password_encrypted
      t.string :nick_name
      t.string :avatar_url
      t.string :user_name
      t.string :location
      t.string :gender
      t.string   "uid",                       limit: 255
      t.string   "access_token",              limit: 255
      t.text     "serial_params",             limit: 16777215
      t.string   "refresh_token",             limit: 255
      t.datetime "authorize_time"

      t.timestamps null: false
    end
  end
end
