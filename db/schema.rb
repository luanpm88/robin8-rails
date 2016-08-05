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

ActiveRecord::Schema.define(version: 20160805063150) do

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

  create_table "addresses", force: :cascade do |t|
    t.integer "addressable_id",   limit: 4
    t.string  "addressable_type", limit: 255
    t.string  "name",             limit: 255
    t.string  "phone",            limit: 255
    t.string  "postcode",         limit: 255
    t.string  "province",         limit: 255
    t.string  "city",             limit: 255
    t.string  "region",           limit: 255
    t.string  "location",         limit: 255
    t.string  "remark",           limit: 255
  end

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

  create_table "agent_kols", force: :cascade do |t|
    t.integer  "agent_id",   limit: 4
    t.integer  "kol_id",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

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

  create_table "alipay_orders", force: :cascade do |t|
    t.string   "trade_no",        limit: 191
    t.string   "alipay_trade_no", limit: 255
    t.decimal  "credits",                     precision: 8, scale: 2
    t.string   "status",          limit: 255,                         default: "pending"
    t.integer  "user_id",         limit: 4
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.decimal  "tax",                         precision: 8, scale: 2, default: 0.0
    t.boolean  "need_invoice",    limit: 1,                           default: false
    t.string   "recharge_from",   limit: 255
  end

  add_index "alipay_orders", ["trade_no"], name: "index_alipay_orders_on_trade_no", unique: true, using: :btree

  create_table "analysis_identities", force: :cascade do |t|
    t.integer  "kol_id",             limit: 4
    t.string   "provider",           limit: 255
    t.string   "name",               limit: 255
    t.string   "password_encrypted", limit: 255
    t.string   "nick_name",          limit: 255
    t.string   "avatar_url",         limit: 255
    t.string   "user_name",          limit: 255
    t.string   "location",           limit: 255
    t.string   "gender",             limit: 255
    t.string   "uid",                limit: 255
    t.string   "access_token",       limit: 255
    t.text     "serial_params",      limit: 16777215
    t.string   "refresh_token",      limit: 255
    t.datetime "authorize_time"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "announcements", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "logo",        limit: 255
    t.string   "banner",      limit: 255
    t.string   "desc",        limit: 255
    t.boolean  "display",     limit: 1,   default: false
    t.integer  "position",    limit: 4,   default: 0
    t.string   "detail_type", limit: 255
    t.string   "url",         limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

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

  add_index "article_actions", ["kol_id"], name: "index_article_actions_on_kol_id", using: :btree

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

  create_table "campaign_applies", force: :cascade do |t|
    t.integer  "campaign_id",         limit: 4
    t.integer  "kol_id",              limit: 4
    t.string   "name",                limit: 255
    t.string   "phone",               limit: 255
    t.string   "weixin_no",           limit: 255
    t.integer  "weixin_friend_count", limit: 4
    t.string   "status",              limit: 255
    t.string   "expect_price",        limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "agree_reason",        limit: 255
    t.string   "remark",              limit: 255
  end

  create_table "campaign_categories", force: :cascade do |t|
    t.integer "campaign_id",      limit: 4
    t.string  "iptc_category_id", limit: 191
  end

  add_index "campaign_categories", ["campaign_id"], name: "index_campaign_categories_on_campaign_id", using: :btree
  add_index "campaign_categories", ["iptc_category_id"], name: "index_campaign_categories_on_iptc_category_id", using: :btree

  create_table "campaign_invites", force: :cascade do |t|
    t.string   "status",            limit: 191
    t.integer  "campaign_id",       limit: 4
    t.integer  "kol_id",            limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.date     "decline_date"
    t.string   "uuid",              limit: 100
    t.string   "share_url",         limit: 255
    t.integer  "total_click",       limit: 4,     default: 0
    t.integer  "avail_click",       limit: 4,     default: 0
    t.datetime "approved_at"
    t.string   "img_status",        limit: 255
    t.string   "screenshot",        limit: 255
    t.string   "reject_reason",     limit: 255
    t.boolean  "is_invited",        limit: 1,     default: false
    t.integer  "share_count",       limit: 4,     default: 0
    t.string   "ocr_status",        limit: 255
    t.string   "ocr_detail",        limit: 255
    t.integer  "campaign_apply_id", limit: 4
    t.integer  "observer_status",   limit: 4,     default: 0
    t.text     "observer_text",     limit: 65535
    t.datetime "upload_time"
    t.datetime "check_time"
    t.boolean  "auto_check",        limit: 1,     default: false
    t.integer  "social_account_id", limit: 4
    t.float    "budget",            limit: 24
  end

  add_index "campaign_invites", ["campaign_id"], name: "index_campaign_invites_on_campaign_id", using: :btree
  add_index "campaign_invites", ["kol_id"], name: "index_campaign_invites_on_kol_id", using: :btree
  add_index "campaign_invites", ["status"], name: "index_campaign_invites_on_status", using: :btree
  add_index "campaign_invites", ["uuid"], name: "index_campaign_invites_on_uuid", unique: true, using: :btree

  create_table "campaign_materials", force: :cascade do |t|
    t.integer  "campaign_id", limit: 4
    t.string   "url_type",    limit: 255
    t.string   "url",         limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

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
    t.string   "other_options",   limit: 255
    t.string   "proxy_ips",       limit: 255
    t.string   "request_url",     limit: 1000
    t.string   "openid",          limit: 255
    t.string   "appid",           limit: 255
    t.string   "device_model",    limit: 255
    t.string   "app_platform",    limit: 255
    t.string   "os_version",      limit: 255
    t.datetime "reg_time"
    t.integer  "transaction_id",  limit: 4
  end

  add_index "campaign_shows", ["kol_id"], name: "index_campaign_shows_on_kol_id", using: :btree

  create_table "campaign_targets", force: :cascade do |t|
    t.string   "target_type",    limit: 255
    t.string   "target_content", limit: 255
    t.integer  "campaign_id",    limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "campaign_targets", ["campaign_id"], name: "index_campaign_targets_on_campaign_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.text     "description",              limit: 16777215
    t.datetime "deadline"
    t.decimal  "budget",                                    precision: 12, scale: 2
    t.integer  "user_id",                  limit: 4
    t.datetime "created_at",                                                                         null: false
    t.datetime "updated_at",                                                                         null: false
    t.integer  "release_id",               limit: 4
    t.text     "concepts",                 limit: 16777215
    t.text     "summaries",                limit: 16777215
    t.text     "hashtags",                 limit: 16777215
    t.string   "content_type",             limit: 255
    t.boolean  "non_cash",                 limit: 1,                                 default: false
    t.string   "short_description",        limit: 255
    t.text     "url",                      limit: 65535
    t.float    "per_action_budget",        limit: 53
    t.datetime "start_time"
    t.text     "message",                  limit: 65535
    t.string   "status",                   limit: 255
    t.integer  "max_action",               limit: 4
    t.integer  "avail_click",              limit: 4,                                 default: 0
    t.integer  "total_click",              limit: 4,                                 default: 0
    t.string   "finish_remark",            limit: 255
    t.string   "img_url",                  limit: 255
    t.datetime "actual_deadline_time"
    t.string   "per_budget_type",          limit: 255
    t.text     "task_description",         limit: 65535
    t.datetime "recruit_start_time"
    t.datetime "recruit_end_time"
    t.string   "address",                  limit: 255
    t.boolean  "hide_brand_name",          limit: 1,                                 default: false
    t.boolean  "end_apply_check",          limit: 1,                                 default: false
    t.decimal  "need_pay_amount",                           precision: 12, scale: 2, default: 0.0
    t.string   "pay_way",                  limit: 255
    t.boolean  "used_voucher",             limit: 1,                                 default: false
    t.decimal  "voucher_amount",                            precision: 12, scale: 2, default: 0.0
    t.string   "trade_number",             limit: 255
    t.integer  "alipay_status",            limit: 4,                                 default: 0
    t.string   "invalid_reason",           limit: 255
    t.float    "actual_per_action_budget", limit: 24
    t.datetime "check_time"
    t.datetime "end_apply_time"
    t.text     "alipay_notify_text",       limit: 65535
    t.string   "campaign_from",            limit: 255,                               default: "pc"
    t.boolean  "budget_editable",          limit: 1,                                 default: true
    t.string   "action_desc",              limit: 255
    t.string   "appid",                    limit: 255
    t.datetime "revoke_time"
    t.string   "invalid_reasons",          limit: 255
    t.string   "admin_desc",               limit: 255
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

  create_table "cpi_regs", force: :cascade do |t|
    t.string   "appid",            limit: 255
    t.string   "reg_ip",           limit: 255
    t.string   "bundle_name",      limit: 255
    t.string   "app_platform",     limit: 255
    t.string   "app_version",      limit: 255
    t.string   "os_version",       limit: 255
    t.string   "device_model",     limit: 255
    t.integer  "campaign_show_id", limit: 4
    t.string   "status",           limit: 255, default: "pending"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "city_name",        limit: 255
  end

  create_table "discounts", force: :cascade do |t|
    t.string   "code",          limit: 255
    t.string   "description",   limit: 255
    t.string   "status",        limit: 255
    t.integer  "amount",        limit: 4
    t.float    "percentage",    limit: 24
    t.datetime "expiry"
    t.integer  "max_count",     limit: 4
    t.boolean  "is_active",     limit: 1,   default: true
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "is_recurring",  limit: 1,   default: false
    t.string   "group_name",    limit: 255
    t.string   "discount_name", limit: 255
  end

  create_table "districts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "city_id",    limit: 4
    t.string   "name_en",    limit: 255
    t.string   "name_abbr",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "download_invitations", force: :cascade do |t|
    t.integer  "inviter_id",      limit: 4
    t.string   "visitor_cookies", limit: 600
    t.string   "visitor_ip",      limit: 255
    t.boolean  "effective",       limit: 1,     default: false
    t.text     "visitor_referer", limit: 65535
    t.text     "visitor_agent",   limit: 65535
    t.string   "app_platform",    limit: 255
    t.string   "device_model",    limit: 255
    t.string   "os_version",      limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "draft_pitches", force: :cascade do |t|
    t.text     "twitter_pitch",  limit: 16777215
    t.text     "email_pitch",    limit: 16777215
    t.integer  "summary_length", limit: 1
    t.string   "email_address",  limit: 255
    t.integer  "release_id",     limit: 4
    t.string   "email_subject",  limit: 2500
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "draft_pitches", ["release_id"], name: "index_draft_pitches_on_release_id", using: :btree

  create_table "email_approves", force: :cascade do |t|
    t.integer  "author_id",  limit: 4
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "outlet",     limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4
  end

  create_table "features", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "slug",        limit: 255
    t.boolean  "is_active",   limit: 1,   default: true
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string   "app_version",  limit: 255
    t.string   "app_platform", limit: 255
    t.string   "os_version",   limit: 255
    t.string   "device_model", limit: 255
    t.string   "content",      limit: 1000
    t.integer  "kol_id",       limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "screenshot",   limit: 255
    t.string   "status",       limit: 255,  default: "pending"
  end

  create_table "followers", force: :cascade do |t|
    t.string   "email",        limit: 255
    t.string   "list_type",    limit: 255
    t.integer  "news_room_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "followers", ["news_room_id"], name: "index_followers_on_news_room_id", using: :btree

  create_table "helper_docs", force: :cascade do |t|
    t.string   "img_url",       limit: 255
    t.string   "question",      limit: 255
    t.text     "answer",        limit: 65535
    t.integer  "helper_tag_id", limit: 4
    t.integer  "sort_weight",   limit: 4,     default: 100
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "helper_tags", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "hot_items", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "origin_url", limit: 255
    t.datetime "publish_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",                   limit: 4
    t.string   "provider",                  limit: 255
    t.string   "uid",                       limit: 50
    t.string   "token",                     limit: 255
    t.string   "token_secret",              limit: 255
    t.string   "name",                      limit: 255
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "url",                       limit: 255
    t.integer  "kol_id",                    limit: 4
    t.string   "avatar_url",                limit: 255
    t.string   "desc",                      limit: 255
    t.string   "audience_age_groups",       limit: 255
    t.string   "audience_gender_ratio",     limit: 255
    t.string   "audience_regions",          limit: 255
    t.integer  "edit_forward",              limit: 4
    t.integer  "origin_publish",            limit: 4
    t.integer  "forward",                   limit: 4
    t.integer  "origin_comment",            limit: 4
    t.integer  "partake_activity",          limit: 4
    t.integer  "panel_discussion",          limit: 4
    t.integer  "undertake_activity",        limit: 4
    t.integer  "image_speak",               limit: 4
    t.integer  "give_speech",               limit: 4
    t.string   "email",                     limit: 255
    t.text     "serial_params",             limit: 16777215
    t.string   "service_type_info",         limit: 255
    t.string   "verify_type_info",          limit: 255
    t.string   "wx_user_name",              limit: 255
    t.string   "alias",                     limit: 255
    t.string   "unionid",                   limit: 255
    t.string   "audience_likes",            limit: 255
    t.string   "audience_friends",          limit: 255
    t.string   "audience_talk_groups",      limit: 255
    t.string   "audience_publish_fres",     limit: 255
    t.boolean  "has_grabed",                limit: 1,        default: false
    t.string   "from_type",                 limit: 255
    t.integer  "followers_count",           limit: 4
    t.integer  "friends_count",             limit: 4
    t.integer  "statuses_count",            limit: 4
    t.datetime "registered_at"
    t.boolean  "verified",                  limit: 1,        default: false
    t.string   "refresh_token",             limit: 255
    t.datetime "refresh_time"
    t.string   "score",                     limit: 255
    t.string   "province",                  limit: 255
    t.string   "city",                      limit: 255
    t.string   "gender",                    limit: 255
    t.boolean  "is_vip",                    limit: 1
    t.boolean  "is_yellow_vip",             limit: 1
    t.datetime "access_token_refresh_time"
  end

  create_table "images", force: :cascade do |t|
    t.integer  "referable_id",   limit: 4
    t.string   "referable_type", limit: 255
    t.string   "avatar",         limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "sub_type",       limit: 255
  end

  create_table "industries", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "industries_news_rooms", force: :cascade do |t|
    t.integer "industry_id",  limit: 4
    t.integer "news_room_id", limit: 4
  end

  add_index "industries_news_rooms", ["industry_id"], name: "index_industries_news_rooms_on_industry_id", using: :btree
  add_index "industries_news_rooms", ["news_room_id"], name: "index_industries_news_rooms_on_news_room_id", using: :btree

  create_table "interested_campaigns", force: :cascade do |t|
    t.integer  "kol_id",       limit: 4,   null: false
    t.integer  "user_id",      limit: 4,   null: false
    t.integer  "campaign_id",  limit: 4,   null: false
    t.string   "status",       limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.datetime "decline_date"
  end

  create_table "invoice_histories", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "phone_number",    limit: 255
    t.string   "credits",         limit: 255
    t.string   "invoice_type",    limit: 255
    t.string   "title",           limit: 255
    t.string   "address",         limit: 255
    t.string   "status",          limit: 255, default: "pending"
    t.string   "tracking_number", limit: 255
    t.integer  "user_id",         limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "invoice_receivers", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "phone_number", limit: 255
    t.string   "address",      limit: 255
    t.integer  "user_id",      limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.string   "invoice_type", limit: 255, default: "common"
    t.integer  "user_id",      limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "ip_scores", force: :cascade do |t|
    t.string   "ip",         limit: 255
    t.integer  "score",      limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "iptc_categories", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.string   "parent",     limit: 8
    t.integer  "level",      limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "scene",      limit: 255
    t.string   "name",       limit: 255
  end

  create_table "kol_announcements", force: :cascade do |t|
    t.integer  "position",   limit: 4
    t.string   "category",   limit: 255
    t.string   "cover",      limit: 255
    t.string   "title",      limit: 255
    t.string   "link",       limit: 255
    t.string   "kol_id",     limit: 255
    t.boolean  "enable",     limit: 1,   default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "kol_categories", force: :cascade do |t|
    t.integer "kol_id",           limit: 4
    t.string  "iptc_category_id", limit: 191
    t.integer "identity_id",      limit: 4
  end

  add_index "kol_categories", ["iptc_category_id"], name: "index_kol_categories_on_iptc_category_id", using: :btree
  add_index "kol_categories", ["kol_id"], name: "index_kol_categories_on_kol_id", using: :btree

  create_table "kol_contacts", force: :cascade do |t|
    t.integer  "kol_id",          limit: 4
    t.string   "name",            limit: 255
    t.string   "mobile",          limit: 20
    t.boolean  "exist",           limit: 1,   default: false
    t.string   "city",            limit: 255
    t.float    "score",           limit: 24
    t.string   "kol_uuid",        limit: 50
    t.float    "influence_score", limit: 24
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "invite_status",   limit: 1,   default: false
    t.datetime "invite_at"
  end

  add_index "kol_contacts", ["kol_id"], name: "index_kol_contacts_on_kol_id", using: :btree
  add_index "kol_contacts", ["kol_uuid"], name: "index_kol_contacts_on_kol_uuid", using: :btree
  add_index "kol_contacts", ["mobile"], name: "index_kol_contacts_on_mobile", using: :btree

  create_table "kol_identity_prices", force: :cascade do |t|
    t.integer  "kol_id",         limit: 4
    t.string   "provider",       limit: 255
    t.string   "name",           limit: 255
    t.string   "follower_count", limit: 255
    t.string   "belong_field",   limit: 255
    t.string   "headline_price", limit: 255
    t.string   "second_price",   limit: 255
    t.string   "single_price",   limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "kol_influence_value_histories", force: :cascade do |t|
    t.integer  "kol_id",                     limit: 4
    t.string   "kol_uuid",                   limit: 50
    t.string   "name",                       limit: 255
    t.string   "avatar_url",                 limit: 255
    t.string   "influence_score",            limit: 255
    t.string   "influence_level",            limit: 255
    t.integer  "location_score",             limit: 4
    t.integer  "mobile_model_score",         limit: 4
    t.integer  "identity_score",             limit: 4
    t.integer  "identity_count_score",       limit: 4
    t.integer  "contact_score",              limit: 4
    t.integer  "base_score",                 limit: 4,   default: 500
    t.integer  "integer",                    limit: 4,   default: 0
    t.integer  "follower_score",             limit: 4,   default: 0
    t.integer  "status_score",               limit: 4,   default: 0
    t.integer  "register_score",             limit: 4,   default: 0
    t.integer  "verify_score",               limit: 4,   default: 0
    t.integer  "campaign_total_click_score", limit: 4,   default: 0
    t.integer  "campaign_avg_click_score",   limit: 4,   default: 0
    t.integer  "article_total_click_score",  limit: 4,   default: 0
    t.integer  "article_avg_click_score",    limit: 4,   default: 0
    t.boolean  "is_auto",                    limit: 1,   default: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  add_index "kol_influence_value_histories", ["kol_id"], name: "index_kol_influence_value_histories_on_kol_id", using: :btree
  add_index "kol_influence_value_histories", ["kol_uuid"], name: "index_kol_influence_value_histories_on_kol_uuid", using: :btree

  create_table "kol_influence_values", force: :cascade do |t|
    t.integer  "kol_id",                     limit: 4
    t.string   "kol_uuid",                   limit: 50
    t.string   "name",                       limit: 255
    t.string   "avatar_url",                 limit: 255
    t.string   "influence_score",            limit: 255
    t.string   "influence_level",            limit: 255
    t.integer  "location_score",             limit: 4
    t.integer  "mobile_model_score",         limit: 4
    t.integer  "identity_score",             limit: 4
    t.integer  "identity_count_score",       limit: 4
    t.integer  "contact_score",              limit: 4
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "share_times",                limit: 4,   default: 0
    t.integer  "read_times",                 limit: 4,   default: 0
    t.integer  "base_score",                 limit: 4,   default: 500
    t.integer  "follower_score",             limit: 4,   default: 0
    t.integer  "status_score",               limit: 4,   default: 0
    t.integer  "register_score",             limit: 4,   default: 0
    t.integer  "verify_score",               limit: 4,   default: 0
    t.integer  "campaign_total_click_score", limit: 4,   default: 0
    t.integer  "campaign_avg_click_score",   limit: 4,   default: 0
    t.integer  "article_total_click_score",  limit: 4,   default: 0
    t.integer  "article_avg_click_score",    limit: 4,   default: 0
  end

  add_index "kol_influence_values", ["kol_uuid"], name: "index_kol_influence_values_on_kol_uuid", using: :btree

  create_table "kol_keywords", force: :cascade do |t|
    t.integer  "kol_id",            limit: 4
    t.integer  "social_account_id", limit: 4
    t.string   "keyword",           limit: 255
    t.string   "weight",            limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "kol_keywords", ["kol_id"], name: "index_kol_keywords_on_kol_id", using: :btree
  add_index "kol_keywords", ["social_account_id"], name: "index_kol_keywords_on_social_account_id", using: :btree

  create_table "kol_professions", force: :cascade do |t|
    t.integer  "kol_id",        limit: 4
    t.integer  "profession_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "kol_professions", ["kol_id"], name: "index_kol_professions_on_kol_id", using: :btree
  add_index "kol_professions", ["profession_id"], name: "index_kol_professions_on_profession_id", using: :btree

  create_table "kol_profile_screens", force: :cascade do |t|
    t.string   "url",         limit: 255
    t.string   "name",        limit: 255
    t.string   "thumbnail",   limit: 255
    t.integer  "kol_id",      limit: 4
    t.string   "social_name", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "kol_shows", force: :cascade do |t|
    t.integer  "kol_id",        limit: 4
    t.string   "title",         limit: 255
    t.string   "cover_url",     limit: 255
    t.text     "desc",          limit: 65535
    t.string   "link",          limit: 255
    t.string   "provider",      limit: 255
    t.integer  "like_count",    limit: 4
    t.integer  "read_count",    limit: 4
    t.integer  "repost_count",  limit: 4
    t.integer  "comment_count", limit: 4
    t.string   "publish_time",  limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "kol_tags", force: :cascade do |t|
    t.integer  "kol_id",     limit: 4
    t.integer  "tag_id",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "kol_tags", ["kol_id"], name: "index_kol_tags_on_kol_id", using: :btree
  add_index "kol_tags", ["tag_id"], name: "index_kol_tags_on_tag_id", using: :btree

  create_table "kols", force: :cascade do |t|
    t.string   "email",                  limit: 191
    t.string   "encrypted_password",     limit: 255
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,                              default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "location",               limit: 255
    t.string   "locale",                 limit: 255
    t.boolean  "is_public",              limit: 1,                              default: true
    t.date     "date_of_birthday"
    t.string   "title",                  limit: 255
    t.string   "industry",               limit: 255
    t.string   "mobile_number",          limit: 191
    t.integer  "gender",                 limit: 4,                              default: 0
    t.string   "country",                limit: 255
    t.string   "province",               limit: 255
    t.string   "city",                   limit: 255
    t.string   "audience_gender_ratio",  limit: 255
    t.string   "audience_age_groups",    limit: 255
    t.integer  "wechat_personal_fans",   limit: 4
    t.string   "wechat_public_name",     limit: 255
    t.string   "wechat_public_id",       limit: 255
    t.integer  "wechat_public_fans",     limit: 4
    t.string   "audience_regions",       limit: 255
    t.string   "avatar",                 limit: 255
    t.integer  "stats_total",            limit: 4,                              default: 0
    t.datetime "stats_total_changed"
    t.decimal  "amount",                               precision: 12, scale: 2, default: 0.0
    t.decimal  "frozen_amount",                        precision: 12, scale: 2, default: 0.0
    t.string   "provider",               limit: 255
    t.string   "social_name",            limit: 255
    t.string   "social_uid",             limit: 255
    t.string   "from_which_campaign",    limit: 255
    t.datetime "forbid_campaign_time"
    t.integer  "five_click_threshold",   limit: 4
    t.integer  "total_click_threshold",  limit: 4
    t.string   "app_platform",           limit: 255
    t.string   "app_version",            limit: 255
    t.string   "private_token",          limit: 80
    t.string   "device_token",           limit: 80
    t.string   "desc",                   limit: 255
    t.string   "alipay_account",         limit: 255
    t.string   "name",                   limit: 255
    t.string   "app_country",            limit: 255
    t.string   "app_province",           limit: 255
    t.string   "app_city",               limit: 255
    t.string   "IMEI",                   limit: 255
    t.string   "IDFA",                   limit: 255
    t.string   "phone_city",             limit: 255
    t.string   "utm_source",             limit: 255
    t.float    "influence_score",        limit: 24,                             default: -1.0
    t.string   "kol_uuid",               limit: 255
    t.datetime "cal_time"
    t.string   "rongcloud_token",        limit: 255
    t.string   "os_version",             limit: 255
    t.string   "device_model",           limit: 255
    t.string   "alipay_name",            limit: 255
    t.string   "invite_code",            limit: 10
    t.integer  "age",                    limit: 4
    t.integer  "weixin_friend_count",    limit: 4
    t.string   "kol_level",              limit: 255
    t.string   "id_card",                limit: 255
    t.string   "job_info",               limit: 255
    t.text     "brief",                  limit: 65535
    t.string   "kol_role",               limit: 255,                            default: "public"
    t.string   "role_apply_status",      limit: 255,                            default: "pending"
    t.datetime "role_check_time"
    t.string   "avatar_url",             limit: 255
    t.boolean  "is_hot",                 limit: 1,                              default: false
  end

  add_index "kols", ["device_token"], name: "index_kols_on_device_token", using: :btree
  add_index "kols", ["email"], name: "index_kols_on_email", unique: true, using: :btree
  add_index "kols", ["forbid_campaign_time"], name: "index_kols_on_forbid_campaign_time", using: :btree
  add_index "kols", ["invite_code"], name: "index_kols_on_invite_code", using: :btree
  add_index "kols", ["is_hot"], name: "index_kols_on_is_hot", using: :btree
  add_index "kols", ["mobile_number"], name: "index_kols_on_mobile_number", unique: true, using: :btree
  add_index "kols", ["private_token"], name: "index_kols_on_private_token", using: :btree
  add_index "kols", ["reset_password_token"], name: "index_kols_on_reset_password_token", unique: true, using: :btree
  add_index "kols", ["updated_at"], name: "index_kols_on_updated_at", using: :btree

  create_table "kols_lists", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "user_id",    limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "kols_count", limit: 4
  end

  create_table "kols_lists_contacts", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "kols_list_id", limit: 4
    t.string   "email",        limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "lottery_activities", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "description",        limit: 255
    t.integer  "total_number",       limit: 4
    t.integer  "actual_number",      limit: 4
    t.string   "lucky_number",       limit: 255
    t.string   "status",             limit: 255, default: "pending"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "lucky_kol_id",       limit: 4
    t.string   "code",               limit: 255
    t.datetime "draw_at"
    t.datetime "published_at"
    t.string   "order_sum",          limit: 255
    t.string   "lottery_number",     limit: 255
    t.string   "lottery_issue",      limit: 255
    t.integer  "lottery_product_id", limit: 4
    t.string   "express_number",     limit: 255
    t.string   "express_name",       limit: 255
    t.datetime "delivered_at"
    t.boolean  "delivered",          limit: 1,   default: false
  end

  create_table "lottery_activity_orders", force: :cascade do |t|
    t.integer  "kol_id",              limit: 4
    t.integer  "lottery_activity_id", limit: 4
    t.integer  "credits",             limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "code",                limit: 255
    t.integer  "number",              limit: 4,   default: 0
    t.string   "status",              limit: 255, default: "pending"
  end

  add_index "lottery_activity_orders", ["kol_id"], name: "index_lottery_activity_orders_on_kol_id", using: :btree
  add_index "lottery_activity_orders", ["lottery_activity_id"], name: "index_lottery_activity_orders_on_lottery_activity_id", using: :btree

  create_table "lottery_activity_tickets", force: :cascade do |t|
    t.integer "lottery_activity_order_id", limit: 4
    t.string  "code",                      limit: 32
  end

  add_index "lottery_activity_tickets", ["code"], name: "index_lottery_activity_tickets_on_code", using: :btree
  add_index "lottery_activity_tickets", ["lottery_activity_order_id"], name: "index_lottery_activity_tickets_on_lottery_activity_order_id", using: :btree

  create_table "lottery_products", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "cover",       limit: 255
    t.integer  "quantity",    limit: 4,   default: 1
    t.integer  "price",       limit: 4,   default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "mailgun_events", force: :cascade do |t|
    t.string   "event_type",      limit: 191
    t.datetime "event_time"
    t.string   "severity",        limit: 255
    t.string   "sender",          limit: 191
    t.string   "recipient",       limit: 255
    t.string   "country",         limit: 255
    t.string   "campaign_name",   limit: 191
    t.text     "delivery_status", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mailgun_events", ["campaign_name"], name: "index_mailgun_events_on_campaign_name", using: :btree
  add_index "mailgun_events", ["event_time"], name: "index_mailgun_events_on_event_time", using: :btree
  add_index "mailgun_events", ["event_type"], name: "index_mailgun_events_on_event_type", using: :btree
  add_index "mailgun_events", ["sender"], name: "index_mailgun_events_on_sender", using: :btree

  create_table "media_lists", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.integer  "user_id",                 limit: 4,   null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
  end

  create_table "media_lists_contacts", force: :cascade do |t|
    t.integer  "media_list_id", limit: 4
    t.integer  "contact_id",    limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "message_type",     limit: 255
    t.boolean  "is_read",          limit: 1,          default: false
    t.datetime "read_at"
    t.string   "title",            limit: 255
    t.string   "name",             limit: 255
    t.string   "desc",             limit: 255
    t.string   "url",              limit: 255
    t.string   "logo_url",         limit: 255
    t.string   "sender",           limit: 255
    t.string   "receiver_type",    limit: 255
    t.integer  "receiver_id",      limit: 4
    t.text     "receiver_ids",     limit: 4294967295
    t.string   "item_type",        limit: 255
    t.string   "item_id",          limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "sub_message_type", limit: 255
  end

  add_index "messages", ["receiver_id"], name: "index_messages_on_receiver_id", using: :btree

  create_table "news_rooms", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.string   "company_name",       limit: 255
    t.string   "room_type",          limit: 255
    t.string   "size",               limit: 255
    t.string   "email",              limit: 255
    t.string   "phone_number",       limit: 255
    t.string   "fax",                limit: 255
    t.string   "web_address",        limit: 255
    t.text     "description",        limit: 16777215
    t.string   "address_1",          limit: 255
    t.string   "address_2",          limit: 255
    t.string   "city",               limit: 255
    t.string   "state",              limit: 255
    t.string   "postal_code",        limit: 255
    t.string   "country",            limit: 255
    t.string   "owner_name",         limit: 255
    t.string   "job_title",          limit: 255
    t.string   "facebook_link",      limit: 255
    t.string   "twitter_link",       limit: 255
    t.string   "linkedin_link",      limit: 255
    t.string   "instagram_link",     limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.text     "tags",               limit: 16777215
    t.string   "subdomain_name",     limit: 191
    t.string   "logo_url",           limit: 255
    t.string   "toll_free_number",   limit: 255
    t.boolean  "default_news_room",  limit: 1,        default: false
    t.boolean  "publish_on_website", limit: 1,        default: false
    t.integer  "releases_count",     limit: 4,        default: 0,     null: false
    t.string   "campaign_name",      limit: 191
    t.integer  "parent_id",          limit: 4
  end

  add_index "news_rooms", ["campaign_name"], name: "index_news_rooms_on_campaign_name", using: :btree
  add_index "news_rooms", ["subdomain_name"], name: "index_news_rooms_on_subdomain_name", unique: true, using: :btree
  add_index "news_rooms", ["user_id"], name: "index_news_rooms_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 120,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["resource_owner_id"], name: "fk_rails_ac82406eb3", using: :btree
  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4
    t.integer  "application_id",    limit: 4
    t.string   "token",             limit: 120, null: false
    t.string   "refresh_token",     limit: 120
    t.integer  "expires_in",        limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                   null: false
    t.string   "uid",          limit: 50,                    null: false
    t.string   "secret",       limit: 255,                   null: false
    t.text     "redirect_uri", limit: 65535,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "union",        limit: 1,     default: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "user_product_id",       limit: 4
    t.integer  "product_id",            limit: 4
    t.string   "card_last_four_digits", limit: 255
    t.string   "card_type",             limit: 255
    t.string   "coupon",                limit: 255
    t.float    "amount",                limit: 24
    t.string   "status",                limit: 255
    t.string   "last_charge_result",    limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "bluesnap_charge_id",    limit: 4
    t.integer  "discount_id",           limit: 4
    t.float    "tax",                   limit: 24,  default: 0.0
    t.string   "currency",              limit: 1
  end

  create_table "pictures", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "imageable_id",   limit: 4
    t.string   "imageable_type", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "type",           limit: 255
  end

  create_table "pitches", force: :cascade do |t|
    t.integer  "user_id",         limit: 4,                        null: false
    t.text     "twitter_pitch",   limit: 16777215
    t.text     "email_pitch",     limit: 16777215
    t.integer  "summary_length",  limit: 1,        default: 5
    t.string   "email_address",   limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "release_id",      limit: 4
    t.string   "email_subject",   limit: 2500
    t.boolean  "email_targets",   limit: 1,        default: false
    t.boolean  "twitter_targets", limit: 1,        default: false
  end

  create_table "pitches_contacts", force: :cascade do |t|
    t.integer  "pitch_id",          limit: 4
    t.integer  "contact_id",        limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "sent_at"
    t.text     "rendered_pitch",    limit: 16777215
    t.string   "unsubscribe_token", limit: 255
  end

  create_table "posts", force: :cascade do |t|
    t.text     "text",            limit: 16777215
    t.integer  "user_id",         limit: 4
    t.datetime "scheduled_date"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "social_networks", limit: 16777215
    t.datetime "performed_at"
    t.boolean  "shrinked_links",  limit: 1
    t.text     "twitter_ids",     limit: 16777215
    t.text     "facebook_ids",    limit: 16777215
    t.text     "linkedin_ids",    limit: 16777215
    t.text     "weibo_ids",       limit: 16777215
    t.text     "wechat_ids",      limit: 16777215
  end

  add_index "posts", ["performed_at"], name: "index_posts_on_performed_at", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "private_kols", force: :cascade do |t|
    t.integer "kol_id",  limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "private_kols", ["kol_id"], name: "index_private_kols_on_kol_id", using: :btree
  add_index "private_kols", ["user_id"], name: "index_private_kols_on_user_id", using: :btree

  create_table "product_discounts", force: :cascade do |t|
    t.integer  "product_id",  limit: 4
    t.integer  "discount_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "product_features", force: :cascade do |t|
    t.integer  "product_id", limit: 4
    t.integer  "feature_id", limit: 4
    t.integer  "validity",   limit: 4
    t.integer  "count",      limit: 4, default: 1
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "slug",        limit: 255
    t.boolean  "is_active",   limit: 1,   default: false
    t.float    "price",       limit: 24
    t.string   "status",      limit: 255
    t.integer  "interval",    limit: 4
    t.string   "name",        limit: 255
    t.integer  "sku_id",      limit: 4
    t.string   "description", limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "is_package",  limit: 1,   default: false
    t.string   "type",        limit: 255
    t.float    "china_price", limit: 24
  end

  create_table "professions", force: :cascade do |t|
    t.string   "name",       limit: 50
    t.string   "label",      limit: 255
    t.integer  "position",   limit: 4
    t.boolean  "enable",     limit: 1,   default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "professions", ["name"], name: "index_professions_on_name", unique: true, using: :btree

  create_table "provinces", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "name_en",    limit: 255
    t.string   "name_abbr",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provinces", ["name"], name: "index_provinces_on_name", using: :btree

  create_table "public_wechat_logins", force: :cascade do |t|
    t.string   "username",           limit: 255
    t.string   "password_encrypted", limit: 255
    t.text     "visitor_cookies",    limit: 65535
    t.text     "redirect_url",       limit: 65535
    t.string   "login_type",         limit: 255
    t.text     "login_cookies",      limit: 65535
    t.datetime "login_time"
    t.string   "ticket",             limit: 255
    t.string   "appid",              limit: 255
    t.string   "uuid",               limit: 255
    t.string   "operation_seq",      limit: 255
    t.string   "status",             limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "kol_id",             limit: 4
    t.string   "token",              limit: 255
  end

  add_index "public_wechat_logins", ["kol_id"], name: "index_public_wechat_logins_on_kol_id", using: :btree

  create_table "push_messages", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "receiver_type",       limit: 255
    t.text     "receiver_ids",        limit: 4294967295
    t.text     "receiver_cids",       limit: 4294967295
    t.string   "receiver_list",       limit: 255
    t.string   "template_type",       limit: 255
    t.text     "template_content",    limit: 65535
    t.boolean  "is_offline",          limit: 1,          default: true
    t.integer  "offline_expire_time", limit: 4,          default: 43200000
    t.string   "result",              limit: 255
    t.text     "result_serial",       limit: 65535
    t.string   "details",             limit: 255
    t.string   "task_id",             limit: 255
    t.string   "status",              limit: 255
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "message_id",          limit: 4
    t.string   "item_type",           limit: 255
    t.integer  "item_id",             limit: 4
  end

  create_table "releases", force: :cascade do |t|
    t.string   "title",                   limit: 255
    t.text     "text",                    limit: 16777215
    t.integer  "news_room_id",            limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "user_id",                 limit: 4
    t.boolean  "is_private",              limit: 1,        default: false
    t.string   "logo_url",                limit: 255
    t.string   "iptc_categories",         limit: 255
    t.text     "concepts",                limit: 16777215
    t.text     "summaries",               limit: 16777215
    t.text     "hashtags",                limit: 16777215
    t.integer  "characters_count",        limit: 4,        default: 0
    t.integer  "words_count",             limit: 4,        default: 0
    t.integer  "sentences_count",         limit: 4,        default: 0
    t.integer  "paragraphs_count",        limit: 4,        default: 0
    t.integer  "adverbs_count",           limit: 4,        default: 0
    t.integer  "adjectives_count",        limit: 4,        default: 0
    t.integer  "nouns_count",             limit: 4,        default: 0
    t.integer  "organizations_count",     limit: 4,        default: 0
    t.integer  "places_count",            limit: 4,        default: 0
    t.integer  "people_count",            limit: 4,        default: 0
    t.string   "slug",                    limit: 191
    t.string   "thumbnail",               limit: 255
    t.datetime "published_at"
    t.boolean  "myprgenie",               limit: 1
    t.boolean  "accesswire",              limit: 1
    t.boolean  "prnewswire",              limit: 1
    t.datetime "myprgenie_published_at"
    t.datetime "accesswire_published_at"
    t.datetime "prnewswire_published_at"
    t.string   "boson_categories",        limit: 255
    t.string   "campaign_name",           limit: 255
  end

  add_index "releases", ["slug"], name: "index_releases_on_slug", using: :btree

  create_table "reward_tasks", force: :cascade do |t|
    t.float    "reward_amount", limit: 24
    t.string   "reward_cycle",  limit: 255
    t.integer  "position",      limit: 4
    t.string   "task_name",     limit: 255
    t.string   "task_type",     limit: 50
    t.integer  "limit",         limit: 4
    t.string   "logo",          limit: 255
    t.boolean  "enable",        limit: 1,   default: true
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "reward_tasks", ["task_type"], name: "index_reward_tasks_on_task_type", using: :btree

  create_table "social_account_professions", force: :cascade do |t|
    t.integer  "social_account_id", limit: 4
    t.integer  "profession_id",     limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "social_account_professions", ["profession_id"], name: "index_social_account_professions_on_profession_id", using: :btree
  add_index "social_account_professions", ["social_account_id"], name: "index_social_account_professions_on_social_account_id", using: :btree

  create_table "social_account_tags", force: :cascade do |t|
    t.integer  "social_account_id", limit: 4
    t.integer  "tag_id",            limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "social_account_tags", ["social_account_id"], name: "index_social_account_tags_on_social_account_id", using: :btree
  add_index "social_account_tags", ["tag_id"], name: "index_social_account_tags_on_tag_id", using: :btree

  create_table "social_accounts", force: :cascade do |t|
    t.integer  "kol_id",          limit: 8
    t.string   "provider",        limit: 255
    t.string   "uid",             limit: 50
    t.string   "username",        limit: 255
    t.string   "homepage",        limit: 255
    t.string   "avatar_url",      limit: 255
    t.text     "brief",           limit: 65535
    t.integer  "like_count",      limit: 8
    t.integer  "followers_count", limit: 8
    t.integer  "friends_count",   limit: 8
    t.integer  "reposts_count",   limit: 8
    t.integer  "statuses_count",  limit: 8
    t.boolean  "verified",        limit: 1,     default: false
    t.string   "province",        limit: 255
    t.string   "city",            limit: 255
    t.string   "gender",          limit: 255
    t.string   "price",           limit: 255
    t.string   "second_price",    limit: 255
    t.string   "repost_price",    limit: 255
    t.string   "screenshot",      limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "social_accounts", ["uid"], name: "index_social_accounts_on_uid", using: :btree

  create_table "stastic_data", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "total_kols_count",            limit: 4
    t.integer  "incr_kols_count",             limit: 4
    t.integer  "total_campaigns_count",       limit: 4
    t.integer  "incr_campaigns_count",        limit: 4
    t.integer  "weibo_kols_count",            limit: 4
    t.integer  "incr_weibo_kols_count",       limit: 4
    t.integer  "weixin_kols_count",           limit: 4
    t.integer  "incr_weixin_kols_count",      limit: 4
    t.integer  "wx_third_kols_count",         limit: 4
    t.integer  "incr_wx_third_kols_count",    limit: 4
    t.integer  "sign_up_kols_count",          limit: 4
    t.integer  "incr_sign_up_kols_count",     limit: 4
    t.text     "from_which_campaign",         limit: 65535
    t.boolean  "is_dealed",                   limit: 1,     default: false
    t.integer  "campaign_invites_count",      limit: 4
    t.integer  "uniq_campaign_invites_count", limit: 4
  end

  create_table "streams", force: :cascade do |t|
    t.integer  "user_id",            limit: 4,        null: false
    t.string   "name",               limit: 255
    t.text     "topics",             limit: 16777215
    t.text     "blogs",              limit: 16777215
    t.string   "sort_column",        limit: 255
    t.integer  "position",           limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "published_at",       limit: 255
    t.text     "keywords",           limit: 16777215
    t.datetime "last_seen_story_at"
  end

  add_index "streams", ["last_seen_story_at"], name: "index_streams_on_last_seen_story_at", using: :btree
  add_index "streams", ["user_id"], name: "index_streams_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "label",      limit: 255
    t.integer  "position",   limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "cover_url",  limit: 255
    t.boolean  "enabled",    limit: 1,   default: true
  end

  create_table "task_records", force: :cascade do |t|
    t.integer  "kol_id",         limit: 4
    t.integer  "reward_task_id", limit: 4
    t.string   "task_type",      limit: 255
    t.integer  "invitees_id",    limit: 4
    t.string   "screenshot",     limit: 255
    t.string   "status",         limit: 191, default: "pending"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "task_records", ["kol_id"], name: "index_task_records_on_kol_id", using: :btree
  add_index "task_records", ["reward_task_id"], name: "index_task_records_on_reward_task_id", using: :btree
  add_index "task_records", ["status"], name: "index_task_records_on_status", using: :btree

  create_table "test_emails", force: :cascade do |t|
    t.integer  "draft_pitch_id", limit: 4
    t.string   "emails",         limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "tmp_identities", force: :cascade do |t|
    t.string   "provider",                  limit: 255
    t.string   "uid",                       limit: 50
    t.string   "token",                     limit: 255
    t.string   "token_secret",              limit: 255
    t.string   "name",                      limit: 255
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "url",                       limit: 255
    t.integer  "kol_id",                    limit: 4
    t.string   "avatar_url",                limit: 255
    t.string   "desc",                      limit: 255
    t.text     "serial_params",             limit: 16777215
    t.string   "service_type_info",         limit: 255
    t.string   "verify_type_info",          limit: 255
    t.string   "wx_user_name",              limit: 255
    t.string   "alias",                     limit: 255
    t.string   "unionid",                   limit: 255
    t.boolean  "has_grabed",                limit: 1,        default: false
    t.string   "from_type",                 limit: 255
    t.integer  "followers_count",           limit: 4
    t.integer  "friends_count",             limit: 4
    t.integer  "statuses_count",            limit: 4
    t.datetime "registered_at"
    t.boolean  "verified",                  limit: 1,        default: false
    t.string   "refresh_token",             limit: 255
    t.datetime "refresh_time"
    t.string   "kol_uuid",                  limit: 50
    t.float    "score",                     limit: 24
    t.string   "province",                  limit: 255
    t.string   "city",                      limit: 255
    t.string   "gender",                    limit: 255
    t.boolean  "is_vip",                    limit: 1
    t.boolean  "is_yellow_vip",             limit: 1
    t.datetime "access_token_refresh_time"
  end

  create_table "tmp_kol_contacts", force: :cascade do |t|
    t.integer  "kol_id",          limit: 4
    t.string   "name",            limit: 255
    t.string   "mobile",          limit: 20
    t.string   "city",            limit: 255
    t.boolean  "exist",           limit: 1,   default: false
    t.float    "score",           limit: 24
    t.string   "kol_uuid",        limit: 50
    t.float    "influence_score", limit: 24
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "invite_status",   limit: 1,   default: false
    t.datetime "invite_at"
  end

  add_index "tmp_kol_contacts", ["kol_id"], name: "index_tmp_kol_contacts_on_kol_id", using: :btree
  add_index "tmp_kol_contacts", ["kol_uuid"], name: "index_tmp_kol_contacts_on_kol_uuid", using: :btree
  add_index "tmp_kol_contacts", ["mobile"], name: "index_tmp_kol_contacts_on_mobile", using: :btree

  create_table "tmp_kol_influence_items", force: :cascade do |t|
    t.integer  "kol_id",              limit: 4
    t.string   "kol_uuid",            limit: 255
    t.string   "item_name",           limit: 255
    t.string   "item_value",          limit: 255
    t.string   "item_score",          limit: 255
    t.text     "item_detail_content", limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "track_url_clicks", force: :cascade do |t|
    t.integer  "track_url_id", limit: 4
    t.string   "cookie",       limit: 255
    t.string   "refer",        limit: 255
    t.string   "user_agent",   limit: 255
    t.string   "vistor_ip",    limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "track_urls", force: :cascade do |t|
    t.string   "origin_url",  limit: 255
    t.string   "short_url",   limit: 255
    t.string   "desc",        limit: 255
    t.integer  "click_count", limit: 4,   default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "account_id",    limit: 4
    t.string   "account_type",  limit: 255
    t.integer  "item_id",       limit: 4
    t.string   "item_type",     limit: 255
    t.string   "direct",        limit: 255
    t.string   "subject",       limit: 255
    t.decimal  "credits",                   precision: 8,  scale: 2
    t.decimal  "amount",                    precision: 8,  scale: 2
    t.decimal  "avail_amount",              precision: 8,  scale: 2
    t.decimal  "frozen_amount",             precision: 8,  scale: 2
    t.integer  "opposite_id",   limit: 4
    t.string   "opposite_type", limit: 255
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.string   "trade_no",      limit: 191
    t.decimal  "tax",                       precision: 12, scale: 2, default: 0.0
  end

  add_index "transactions", ["trade_no"], name: "index_transactions_on_trade_no", unique: true, using: :btree

  create_table "unsubscribe_emails", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "email",      limit: 191
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "unsubscribe_emails", ["email"], name: "index_unsubscribe_emails_on_email", using: :btree
  add_index "unsubscribe_emails", ["user_id"], name: "index_unsubscribe_emails_on_user_id", using: :btree

  create_table "user_discounts", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "discount_id", limit: 4
    t.boolean  "is_used",     limit: 1
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "user_features", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "feature_id",      limit: 4
    t.integer  "product_id",      limit: 4
    t.integer  "available_count", limit: 4, default: 0
    t.integer  "max_count",       limit: 4
    t.date     "reset_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "user_products", force: :cascade do |t|
    t.integer  "user_id",                  limit: 4
    t.integer  "product_id",               limit: 4
    t.string   "status",                   limit: 255
    t.string   "cancellation_reason",      limit: 255
    t.string   "bluesnap_shopper_id",      limit: 255
    t.float    "recurring_amount",         limit: 24
    t.float    "charged_amount",           limit: 24
    t.date     "next_charge_date"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.date     "expiry"
    t.datetime "cancelled_at"
    t.integer  "bluesnap_subscription_id", limit: 4
    t.datetime "suspended_at"
    t.integer  "bluesnap_order_id",        limit: 4
  end

  create_table "user_sign_in_records", force: :cascade do |t|
    t.string   "sign_in_token", limit: 255
    t.string   "user_id",       limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 191
    t.string   "encrypted_password",     limit: 255
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,                            default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token",     limit: 191
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "name",                   limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "company",                limit: 255
    t.string   "time_zone",              limit: 255
    t.string   "invitation_token",       limit: 191
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",       limit: 4
    t.integer  "invited_by_id",          limit: 4
    t.string   "invited_by_type",        limit: 255
    t.boolean  "is_primary",             limit: 1,                            default: true
    t.string   "avatar_url",             limit: 255
    t.string   "slug",                   limit: 191
    t.string   "locale",                 limit: 255
    t.decimal  "amount",                             precision: 12, scale: 2, default: 0.0
    t.decimal  "frozen_amount",                      precision: 12, scale: 2, default: 0.0
    t.string   "mobile_number",          limit: 255
    t.string   "utm_source",             limit: 255
    t.string   "url",                    limit: 255
    t.string   "description",            limit: 255
    t.string   "keywords",               limit: 255
    t.string   "real_name",              limit: 255
    t.decimal  "appliable_credits",                  precision: 12, scale: 2, default: 0.0
    t.integer  "kol_id",                 limit: 4
    t.string   "appid",                  limit: 255
    t.boolean  "is_active",              limit: 1,                            default: true
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["is_primary"], name: "index_users_on_is_primary", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  create_table "wechat_article_performances", force: :cascade do |t|
    t.date     "period"
    t.integer  "reached_peoples", limit: 4
    t.integer  "page_views",      limit: 4
    t.integer  "read_more",       limit: 4
    t.integer  "favourite",       limit: 4
    t.text     "status",          limit: 16777215
    t.text     "claim_reason",    limit: 16777215
    t.text     "campaign_name",   limit: 16777215
    t.text     "company_name",    limit: 16777215
    t.integer  "article_id",      limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "wechat_article_performances", ["article_id"], name: "index_wechat_article_performances_on_article_id", using: :btree

  create_table "weibo_invites", force: :cascade do |t|
    t.integer  "campaign_id", limit: 4
    t.integer  "weibo_id",    limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "weibo_invites", ["campaign_id"], name: "index_weibo_invites_on_campaign_id", using: :btree
  add_index "weibo_invites", ["weibo_id"], name: "index_weibo_invites_on_weibo_id", using: :btree

  create_table "weibos", force: :cascade do |t|
    t.integer  "pressr_id",  limit: 8
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "full_name",  limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "withdraws", force: :cascade do |t|
    t.integer  "kol_id",        limit: 4
    t.string   "real_name",     limit: 255
    t.integer  "credits",       limit: 4
    t.string   "withdraw_type", limit: 255
    t.string   "alipay_no",     limit: 255
    t.string   "bank_name",     limit: 255
    t.string   "bank_no",       limit: 255
    t.string   "status",        limit: 255
    t.string   "remark",        limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_foreign_key "campaign_targets", "campaigns"
  add_foreign_key "oauth_access_grants", "kols", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "kols", column: "resource_owner_id"
  add_foreign_key "weibo_invites", "campaigns"
  add_foreign_key "weibo_invites", "weibos"
end
