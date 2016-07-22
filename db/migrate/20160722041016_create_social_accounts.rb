class CreateSocialAccounts < ActiveRecord::Migration
  def change
    create_table :social_accounts do |t|
      t.integer  "kol_id",                    limit: 8
      t.string   "provider",                  limit: 255
      t.string   "uid",                       limit: 50
      t.string   "username",                      limit: 255
      t.string   "homepage",                       limit: 255
      t.string   "avatar_url",                limit: 255
      t.string   "brief",                limit: 255
      t.integer  "like_count",           limit: 8
      t.integer  "followers_count",           limit: 8
      t.integer  "friends_count",             limit: 8
      t.integer  "reposts_count",             limit: 8
      t.integer  "statuses_count",            limit: 8
      t.boolean  "verified",                  limit: 1,        default: false
      t.string   "province",                  limit: 255
      t.string   "city",                      limit: 255
      t.string   "gender",                    limit: 255
      t.string   "price",                     limit: 255
      t.string   "screenshot",                limit: 255

      t.timestamps null: false
    end
  end
end
