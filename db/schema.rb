# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160408055943) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 191
    t.text     "body",          limit: 16777215
    t.string   "resource_id",   limit: 191
    t.string   "resource_type", limit: 191
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 191
    t.string   "encrypted_password",     limit: 255
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_super_admin",         limit: 1,   default: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "alerts", force: :cascade do |t|
    t.integer  "stream_id",          limit: 4
    t.string   "email",              limit: 255
    t.string   "phone",              limit: 255
    t.boolean  "enabled",            limit: 1,   default: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.datetime "last_email_sent_at"
    t.datetime "last_text_sent_at"
  end

  add_index "alerts", ["enabled"], name: "index_alerts_on_enabled", using: :btree
  add_index "alerts", ["last_email_sent_at"], name: "index_alerts_on_last_email_sent_at", using: :btree
  add_index "alerts", ["last_text_sent_at"], name: "index_alerts_on_last_text_sent_at", using: :btree
  add_index "alerts", ["stream_id"], name: "index_alerts_on_stream_id", using: :btree

  create_table "app_upgrades", force: :cascade do |t|
    t.string   "app_platform",  limit: 255
    t.string   "app_version",   limit: 255
    t.datetime "release_at"
    t.string   "release_note",  limit: 255
    t.string   "download_url",  limit: 255
    t.boolean  "force_upgrade", limit: 1
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "article_actions", force: :cascade do |t|
    t.integer  "kol_id",             limit: 4
    t.string   "article_id",         limit: 255
    t.string   "article_title",      limit: 255
    t.string   "article_url",        limit: 255
    t.string   "article_avatar_url", limit: 255
    t.string   "article_author",     limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "uuid",               limit: 255
    t.boolean  "look",               limit: 1,   default: false
    t.boolean  "forward",            limit: 1,   default: false
    t.boolean  "collect",            limit: 1,   default: false
    t.boolean  "like",               limit: 1,   default: false
  end

  create_table "article_comments", force: :cascade do |t|
    t.text     "text",         limit: 16777215
    t.string   "comment_type", limit: 191
    t.integer  "sender_id",    limit: 4
    t.string   "sender_type",  limit: 191
    t.integer  "article_id",   limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "article_comments", ["article_id"], name: "index_article_comments_on_article_id", using: :btree
  add_index "article_comments", ["comment_type"], name: "index_article_comments_on_comment_type", using: :btree
  add_index "article_comments", ["sender_type", "sender_id"], name: "index_article_comments_on_sender_type_and_sender_id", using: :btree

  create_table "articles", force: :cascade do |t|
    t.text     "text",          limit: 16777215
    t.integer  "campaign_id",   limit: 4
    t.integer  "kol_id",        limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "tracking_code", limit: 255
  end

  add_index "articles", ["campaign_id"], name: "index_articles_on_campaign_id", using: :btree
  add_index "articles", ["kol_id"], name: "index_articles_on_kol_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "url",             limit: 255
    t.string   "attachment_type", limit: 255
    t.integer  "imageable_id",    limit: 4
    t.string   "imageable_type",  limit: 191
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "name",            limit: 255
    t.string   "thumbnail",       limit: 255
  end

  add_index "attachments", ["imageable_type", "imageable_id"], name: "index_attachments_on_imageable_type_and_imageable_id", using: :btree

  create_table "campaign_action_urls", force: :cascade do |t|
    t.integer  "campaign_id", limit: 4
    t.string   "action_url",  limit: 255
    t.string   "short_url",   limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "identifier",  limit: 255
  end

  create_table "campaign_actions", force: :cascade do |t|
    t.integer  "kol_id",      limit: 4
    t.integer  "campaign_id", limit: 4
    t.string   "action",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "campaign_categories", force: :cascade do |t|
    t.integer "campaign_id",      limit: 4
    t.string  "iptc_category_id", limit: 191
  end

  add_index "campaign_categories", ["campaign_id"], name: "index_campaign_categories_on_campaign_id", using: :btree
  add_index "campaign_categories", ["iptc_category_id"], name: "index_campaign_categories_on_iptc_category_id", using: :btree

  create_table "campaign_invites", force: :cascade do |t|
    t.string   "status",        limit: 191
    t.integer  "campaign_id",   limit: 4
    t.integer  "kol_id",        limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.date     "decline_date"
    t.string   "uuid",          limit: 255
    t.string   "share_url",     limit: 255
    t.integer  "total_click",   limit: 4,   default: 0
    t.integer  "avail_click",   limit: 4,   default: 0
    t.datetime "approved_at"
    t.string   "img_status",    limit: 255
    t.string   "screenshot",    limit: 255
    t.string   "reject_reason", limit: 255
    t.boolean  "is_invited",    limit: 1,   default: false
    t.integer  "share_count",   limit: 4,   default: 0
    t.string   "ocr_status",    limit: 255
    t.string   "ocr_detail",    limit: 255
  end

  add_index "campaign_invites", ["campaign_id"], name: "index_campaign_invites_on_campaign_id", using: :btree
  add_index "campaign_invites", ["kol_id"], name: "index_campaign_invites_on_kol_id", using: :btree
  add_index "campaign_invites", ["status"], name: "index_campaign_invites_on_status", using: :btree

  create_table "campaign_shows", force: :cascade do |t|
    t.integer  "campaign_id",     limit: 4
    t.integer  "kol_id",          limit: 4
    t.text     "visitor_cookie",  limit: 65535
    t.string   "visitor_ip",      limit: 255
    t.datetime "visit_time"
    t.string   "status",          limit: 255
    t.string   "remark",          limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "visitor_agent",   limit: 3555
    t.string   "visitor_referer", limit: 3555
  end

  create_table "campaign_targets", force: :cascade do |t|
    t.string   "target_type",    limit: 255
    t.string   "target_content", limit: 255
    t.integer  "campaign_id",    limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "campaign_targets", ["campaign_id"], name: "index_campaign_targets_on_campaign_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.text     "description",          limit: 16777215
    t.datetime "deadline"
    t.decimal  "budget",                                precision: 10
    t.integer  "user_id",              limit: 4
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.integer  "release_id",           limit: 4
    t.text     "concepts",             limit: 16777215
    t.text     "summaries",            limit: 16777215
    t.text     "hashtags",             limit: 16777215
    t.string   "content_type",         limit: 255
    t.boolean  "non_cash",             limit: 1,                       default: false
    t.string   "short_description",    limit: 255
    t.text     "url",                  limit: 65535
    t.float    "per_action_budget",    limit: 53
    t.datetime "start_time"
    t.text     "message",              limit: 65535
    t.string   "status",               limit: 255
    t.integer  "max_action",           limit: 4
    t.integer  "avail_click",          limit: 4,                       default: 0
    t.integer  "total_click",          limit: 4,                       default: 0
    t.string   "finish_remark",        limit: 255
    t.string   "img_url",              limit: 255
    t.datetime "actual_deadline_time"
    t.string   "per_budget_type",      limit: 255
  end

  add_index "campaigns", ["user_id"], name: "index_campaigns_on_user_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "province_id", limit: 4
    t.integer  "level",       limit: 4
    t.string   "zip_code",    limit: 255
    t.string   "name_en",     limit: 255
    t.string   "name_abbr",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "author_id",           limit: 4
    t.string   "first_name",          limit: 255
    t.string   "last_name",           limit: 255
    t.string   "email",               limit: 191
    t.string   "twitter_screen_name", limit: 191
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "origin",              limit: 1,   default: 0
    t.string   "outlet",              limit: 255
  end

  add_index "contacts", ["author_id", "origin"], name: "index_contacts_on_author_id_and_origin", using: :btree
  add_index "contacts", ["email", "origin"], name: "index_contacts_on_email_and_origin", using: :btree
  add_index "contacts", ["twitter_screen_name", "origin"], name: "index_contacts_on_twitter_screen_name_and_origin", using: :btree

