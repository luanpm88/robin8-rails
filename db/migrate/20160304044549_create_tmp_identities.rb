class CreateTmpIdentities < ActiveRecord::Migration
  def change
    create_table :tmp_identities do |t|
      t.string   "provider",              limit: 255
      t.string   "uid",                   limit: 255
      t.string   "token",                 limit: 255
      t.string   "token_secret",          limit: 255
      t.string   "name",                  limit: 255
      t.datetime "created_at",                                             null: false
      t.datetime "updated_at",                                             null: false
      t.string   "url",                   limit: 255
      t.integer  "kol_id",                limit: 4
      t.string   "avatar_url",            limit: 255
      t.string   "desc",                  limit: 255
      t.text     "serial_params",         limit: 16777215
      t.string   "service_type_info",     limit: 255
      t.string   "verify_type_info",      limit: 255
      t.string   "wx_user_name",          limit: 255
      t.string   "alias",                 limit: 255
      t.string   "unionid",               limit: 255
      t.boolean  "has_grabed",            limit: 1,        default: false
      t.string   "from_type",             limit: 255,      default: "pc"
      t.integer  "followers_count",       limit: 4
      t.integer  "friends_count",         limit: 4
      t.integer  "statuses_count",        limit: 4
      t.datetime "registered_at"
      t.boolean  "verified",              limit: 1,        default: false
      t.string   "refresh_token",         limit: 255
      t.datetime "refresh_time"

      t.string :kol_uuid
      t.float :score
    end

    add_column :identities, :score, :string
  end
end
