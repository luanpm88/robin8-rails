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

ActiveRecord::Schema.define(version: 20160310060042) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
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

  create_table "article_comments", force: :cascade do |t|
    t.text     "text",         limit: 65535
    t.string   "comment_type", limit: 255
    t.integer  "sender_id",    limit: 4
    t.string   "sender_type",  limit: 255
    t.integer  "article_id",   limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "article_comments", ["article_id"], name: "index_article_comments_on_article_id", using: :btree
  add_index "article_comments", ["comment_type"], name: "index_article_comments_on_comment_type", using: :btree
  add_index "article_comments", ["sender_type", "sender_id"], name: "index_article_comments_on_sender_type_and_sender_id", using: :btree

  create_table "articles", force: :cascade do |t|
    t.text     "text",          limit: 65535
    t.integer  "campaign_id",   limit: 4
    t.integer  "kol_id",        limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "tracking_code", limit: 255
  end

  add_index "articles", ["campaign_id"], name: "index_articles_on_campaign_id", using: :btree
  add_index "articles", ["kol_id"], name: "index_articles_on_kol_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "url",             limit: 255
    t.string   "attachment_type", limit: 255
    t.integer  "imageable_id",    limit: 4
    t.string   "imageable_type",  limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "name",            limit: 255
    t.string   "thumbnail",       limit: 255
  end

  add_index "attachments", ["imageable_type", "imageable_id"], name: "index_attachments_on_imageable_type_and_imageable_id", using: :btree

  create_table "campaign_action_urls", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "campaign_id", limit: 4
    t.string   "action_url",  limit: 255
    t.string   "short_url",   limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "uuid",        limit: 255
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
    t.string  "iptc_category_id", limit: 255
  end

  add_index "campaign_categories", ["campaign_id"], name: "index_campaign_categories_on_campaign_id", using: :btree
  add_index "campaign_categories", ["iptc_category_id"], name: "index_campaign_categories_on_iptc_category_id", using: :btree

  create_table "campaign_invites", force: :cascade do |t|
    t.string   "status",        limit: 255
    t.integer  "campaign_id",   limit: 4
    t.integer  "kol_id",        limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.date     "decline_date"
    t.string   "uuid",          limit: 255
    t.string   "share_url",     limit: 255
    t.integer  "total_click",   limit: 4,   default: 0
    t.integer  "avail_click",   limit: 4,   default: 0
    t.datetime "approved_at"
    t.string   "img_status",    limit: 255, default: "pending"
    t.string   "screenshot",    limit: 255
    t.string   "reject_reason", limit: 255
    t.boolean  "is_invited",    limit: 1,   default: false
    t.integer  "share_count",   limit: 4,   default: 0
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

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.text     "description",          limit: 65535
    t.datetime "deadline"
    t.decimal  "budget",                             precision: 10
    t.integer  "user_id",              limit: 4
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "release_id",           limit: 4
    t.text     "concepts",             limit: 65535
    t.text     "summaries",            limit: 65535
    t.text     "hashtags",             limit: 65535
    t.string   "content_type",         limit: 255
    t.boolean  "non_cash",             limit: 1,                    default: false
    t.string   "short_description",    limit: 255
    t.text     "url",                  limit: 65535
    t.float    "per_action_budget",    limit: 53
    t.datetime "start_time"
    t.text     "message",              limit: 65535
    t.string   "status",               limit: 255
    t.integer  "max_action",           limit: 4
    t.integer  "avail_click",          limit: 4,                    default: 0
    t.integer  "total_click",          limit: 4,                    default: 0
    t.string   "finish_remark",        limit: 255
    t.string   "img_url",              limit: 255
    t.datetime "actual_deadline_time"
    t.string   "per_budget_type",      limit: 255,                  default: "click"
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
    t.string   "email",               limit: 255
    t.string   "twitter_screen_name", limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "origin",              limit: 1,   default: 0
    t.string   "outlet",              limit: 255
  end

  add_index "contacts", ["author_id", "origin"], name: "index_contacts_on_author_id_and_origin", using: :btree
  add_index "contacts", ["email", "origin"], name: "index_contacts_on_email_and_origin", using: :btree
  add_index "contacts", ["twitter_screen_name", "origin"], name: "index_contacts_on_twitter_screen_name_and_origin", using: :btree

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

  create_table "draft_pitches", force: :cascade do |t|
    t.text     "twitter_pitch",  limit: 65535
    t.text     "email_pitch",    limit: 65535
    t.integer  "summary_length", limit: 1
    t.string   "email_address",  limit: 255
    t.integer  "release_id",     limit: 4
    t.string   "email_subject",  limit: 2500
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
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
    t.string   "content",      limit: 255
    t.integer  "kol_id",       limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "followers", force: :cascade do |t|
    t.string   "email",        limit: 255
    t.string   "list_type",    limit: 255
    t.integer  "news_room_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "followers", ["news_room_id"], name: "index_followers_on_news_room_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.string   "provider",              limit: 255
    t.string   "uid",                   limit: 255
    t.string   "token",                 limit: 255
    t.string   "token_secret",          limit: 255
    t.string   "name",                  limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "url",                   limit: 255
    t.integer  "kol_id",                limit: 4
    t.string   "avatar_url",            limit: 255
    t.string   "desc",                  limit: 255
    t.string   "audience_age_groups",   limit: 255
    t.string   "audience_gender_ratio", limit: 255
    t.string   "audience_regions",      limit: 255
    t.integer  "edit_forward",          limit: 4
    t.integer  "origin_publish",        limit: 4
    t.integer  "forward",               limit: 4
    t.integer  "origin_comment",        limit: 4
    t.integer  "partake_activity",      limit: 4
    t.integer  "panel_discussion",      limit: 4
    t.integer  "undertake_activity",    limit: 4
    t.integer  "image_speak",           limit: 4
    t.integer  "give_speech",           limit: 4
    t.string   "email",                 limit: 255
    t.text     "serial_params",         limit: 65535
    t.string   "service_type_info",     limit: 255
    t.string   "verify_type_info",      limit: 255
    t.string   "wx_user_name",          limit: 255
    t.string   "alias",                 limit: 255
    t.string   "unionid",               limit: 255
    t.string   "audience_likes",        limit: 255
    t.string   "audience_friends",      limit: 255
    t.string   "audience_talk_groups",  limit: 255
    t.string   "audience_publish_fres", limit: 255
    t.boolean  "has_grabed",            limit: 1,     default: false
    t.string   "from_type",             limit: 255,   default: "pc"
    t.integer  "followers_count",       limit: 4
    t.integer  "friends_count",         limit: 4
    t.integer  "statuses_count",        limit: 4
    t.datetime "registered_at"
    t.boolean  "verified",              limit: 1,     default: false
    t.string   "refresh_token",         limit: 255
    t.datetime "refresh_time"
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

  create_table "iptc_categories", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.string   "parent",     limit: 8
    t.integer  "level",      limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "scene",      limit: 255
    t.string   "name",       limit: 255
  end

  create_table "kol_categories", force: :cascade do |t|
    t.integer "kol_id",           limit: 4
    t.string  "iptc_category_id", limit: 255
    t.integer "identity_id",      limit: 4
  end

  add_index "kol_categories", ["iptc_category_id"], name: "index_kol_categories_on_iptc_category_id", using: :btree
  add_index "kol_categories", ["kol_id"], name: "index_kol_categories_on_kol_id", using: :btree

  create_table "kol_profile_screens", force: :cascade do |t|
    t.string   "url",         limit: 255
    t.string   "name",        limit: 255
    t.string   "thumbnail",   limit: 255
    t.integer  "kol_id",      limit: 4
    t.string   "social_name", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "kol_tags", force: :cascade do |t|
    t.integer  "kol_id",     limit: 4
    t.integer  "tag_id",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "kols", force: :cascade do |t|
    t.string   "email",                            limit: 255
    t.string   "encrypted_password",               limit: 255,                          default: "",       null: false
    t.string   "reset_password_token",             limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    limit: 4,                            default: 0,        null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",               limit: 255
    t.string   "last_sign_in_ip",                  limit: 255
    t.string   "confirmation_token",               limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                       limit: 255
    t.string   "last_name",                        limit: 255
    t.string   "location",                         limit: 255
    t.string   "locale",                           limit: 255
    t.boolean  "is_public",                        limit: 1,                            default: true
    t.date     "date_of_birthday"
    t.string   "title",                            limit: 255
    t.string   "industry",                         limit: 255
    t.string   "mobile_number",                    limit: 255
    t.integer  "gender",                           limit: 4,                            default: 0
    t.string   "country",                          limit: 255
    t.string   "province",                         limit: 255
    t.string   "city",                             limit: 255
    t.string   "audience_gender_ratio",            limit: 255,                          default: "50:50"
    t.string   "audience_age_groups",              limit: 255,                          default: ""
    t.integer  "wechat_personal_fans",             limit: 4
    t.string   "wechat_public_name",               limit: 255
    t.string   "wechat_public_id",                 limit: 255
    t.integer  "wechat_public_fans",               limit: 4
    t.string   "audience_regions",                 limit: 255,                          default: ""
    t.integer  "monetize_post",                    limit: 4
    t.integer  "monetize_post_weibo",              limit: 4
    t.integer  "monetize_post_personal",           limit: 4
    t.integer  "monetize_post_public1st",          limit: 4
    t.integer  "monetize_post_public2nd",          limit: 4
    t.integer  "monetize_create",                  limit: 4
    t.integer  "monetize_create_weibo",            limit: 4
    t.integer  "monetize_create_personal",         limit: 4
    t.integer  "monetize_create_public1st",        limit: 4
    t.integer  "monetize_create_public2nd",        limit: 4
    t.integer  "monetize_share",                   limit: 4
    t.integer  "monetize_share_weibo",             limit: 4
    t.integer  "monetize_share_personal",          limit: 4
    t.integer  "monetize_share_public1st",         limit: 4
    t.integer  "monetize_share_public2nd",         limit: 4
    t.integer  "monetize_review",                  limit: 4
    t.integer  "monetize_review_weibo",            limit: 4
    t.integer  "monetize_review_personal",         limit: 4
    t.integer  "monetize_review_public1st",        limit: 4
    t.integer  "monetize_review_public2nd",        limit: 4
    t.integer  "monetize_speech",                  limit: 4
    t.integer  "monetize_speech_weibo",            limit: 4
    t.integer  "monetize_speech_personal",         limit: 4
    t.integer  "monetize_speech_public1st",        limit: 4
    t.integer  "monetize_speech_public2nd",        limit: 4
    t.integer  "monetize_event",                   limit: 4
    t.integer  "monetize_focus",                   limit: 4
    t.integer  "monetize_party",                   limit: 4
    t.integer  "monetize_endorsements",            limit: 4
    t.boolean  "monetize_interested_post",         limit: 1
    t.boolean  "monetize_interested_create",       limit: 1
    t.boolean  "monetize_interested_share",        limit: 1
    t.boolean  "monetize_interested_review",       limit: 1
    t.boolean  "monetize_interested_speech",       limit: 1
    t.boolean  "monetize_interested_event",        limit: 1
    t.boolean  "monetize_interested_focus",        limit: 1
    t.boolean  "monetize_interested_party",        limit: 1
    t.boolean  "monetize_interested_endorsements", limit: 1
    t.string   "avatar",                           limit: 255
    t.integer  "stats_total",                      limit: 4,                            default: 0
    t.datetime "stats_total_changed"
    t.decimal  "amount",                                       precision: 12, scale: 2, default: 0.0
    t.decimal  "frozen_amount",                                precision: 12, scale: 2, default: 0.0
    t.string   "provider",                         limit: 255,                          default: "signup"
    t.string   "social_name",                      limit: 255
    t.string   "social_uid",                       limit: 255
    t.string   "from_which_campaign",              limit: 255
    t.datetime "forbid_campaign_time"
    t.integer  "five_click_threshold",             limit: 4
    t.integer  "total_click_threshold",            limit: 4
    t.string   "app_platform",                     limit: 255
    t.string   "app_version",                      limit: 255
    t.string   "private_token",                    limit: 255
    t.string   "device_token",                     limit: 255
    t.string   "desc",                             limit: 255
    t.string   "alipay_account",                   limit: 255
    t.string   "name",                             limit: 255
    t.string   "app_country",                      limit: 255
    t.string   "app_province",                     limit: 255
    t.string   "app_city",                         limit: 255
    t.string   "IMEI",                             limit: 255
    t.string   "IDFA",                             limit: 255
    t.string   "phone_city",                       limit: 255
    t.string   "utm_source",                       limit: 255
  end

  add_index "kols", ["email"], name: "index_kols_on_email", unique: true, using: :btree
  add_index "kols", ["mobile_number"], name: "index_kols_on_mobile_number", unique: true, using: :btree
  add_index "kols", ["reset_password_token"], name: "index_kols_on_reset_password_token", unique: true, using: :btree

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

  create_table "mailgun_events", force: :cascade do |t|
    t.string   "event_type",      limit: 255
    t.datetime "event_time"
    t.string   "severity",        limit: 255
    t.string   "sender",          limit: 255
    t.string   "recipient",       limit: 255
    t.string   "country",         limit: 255
    t.string   "campaign_name",   limit: 255
    t.text     "delivery_status", limit: 65535
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
    t.string   "message_type",  limit: 255
    t.boolean  "is_read",       limit: 1,     default: false
    t.datetime "read_at"
    t.string   "title",         limit: 255
    t.string   "name",          limit: 255
    t.string   "desc",          limit: 255
    t.string   "url",           limit: 255
    t.string   "logo_url",      limit: 255
    t.string   "sender",        limit: 255
    t.string   "receiver_type", limit: 255
    t.integer  "receiver_id",   limit: 4
    t.text     "receiver_ids",  limit: 65535
    t.string   "item_type",     limit: 255
    t.string   "item_id",       limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "news_rooms", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.string   "company_name",       limit: 255
    t.string   "room_type",          limit: 255
    t.string   "size",               limit: 255
    t.string   "email",              limit: 255
    t.string   "phone_number",       limit: 255
    t.string   "fax",                limit: 255
    t.string   "web_address",        limit: 255
    t.text     "description",        limit: 65535
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
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.text     "tags",               limit: 65535
    t.string   "subdomain_name",     limit: 255
    t.string   "logo_url",           limit: 255
    t.string   "toll_free_number",   limit: 255
    t.boolean  "default_news_room",  limit: 1,     default: false
    t.boolean  "publish_on_website", limit: 1,     default: false
    t.integer  "releases_count",     limit: 4,     default: 0,     null: false
    t.string   "campaign_name",      limit: 255
    t.integer  "parent_id",          limit: 4
  end

  add_index "news_rooms", ["campaign_name"], name: "index_news_rooms_on_campaign_name", using: :btree
  add_index "news_rooms", ["subdomain_name"], name: "index_news_rooms_on_subdomain_name", unique: true, using: :btree
  add_index "news_rooms", ["user_id"], name: "index_news_rooms_on_user_id", using: :btree

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

  create_table "pitches", force: :cascade do |t|
    t.integer  "user_id",         limit: 4,                     null: false
    t.text     "twitter_pitch",   limit: 65535
    t.text     "email_pitch",     limit: 65535
    t.integer  "summary_length",  limit: 1,     default: 5
    t.string   "email_address",   limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "release_id",      limit: 4
    t.string   "email_subject",   limit: 2500
    t.boolean  "email_targets",   limit: 1,     default: false
    t.boolean  "twitter_targets", limit: 1,     default: false
  end

  create_table "pitches_contacts", force: :cascade do |t|
    t.integer  "pitch_id",          limit: 4
    t.integer  "contact_id",        limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "sent_at"
    t.text     "rendered_pitch",    limit: 65535
    t.string   "unsubscribe_token", limit: 255
  end

  create_table "posts", force: :cascade do |t|
    t.text     "text",            limit: 65535
    t.integer  "user_id",         limit: 4
    t.datetime "scheduled_date"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "social_networks", limit: 65535
    t.datetime "performed_at"
    t.boolean  "shrinked_links",  limit: 1
    t.text     "twitter_ids",     limit: 65535
    t.text     "facebook_ids",    limit: 65535
    t.text     "linkedin_ids",    limit: 65535
    t.text     "weibo_ids",       limit: 65535
    t.text     "wechat_ids",      limit: 65535
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

  create_table "provinces", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "name_en",    limit: 255
    t.string   "name_abbr",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provinces", ["name"], name: "index_provinces_on_name", using: :btree

  create_table "push_messages", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "receiver_type",       limit: 255
    t.text     "receiver_ids",        limit: 65535
    t.text     "receiver_cids",       limit: 65535
    t.string   "receiver_list",       limit: 255
    t.string   "template_type",       limit: 255
    t.text     "template_content",    limit: 65535
    t.boolean  "is_offline",          limit: 1,     default: true
    t.integer  "offline_expire_time", limit: 4,     default: 43200000
    t.string   "result",              limit: 255
    t.text     "result_serial",       limit: 65535
    t.string   "details",             limit: 255
    t.string   "task_id",             limit: 255
    t.string   "status",              limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  create_table "releases", force: :cascade do |t|
    t.string   "title",                   limit: 255
    t.text     "text",                    limit: 65535
    t.integer  "news_room_id",            limit: 4
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "user_id",                 limit: 4
    t.boolean  "is_private",              limit: 1,     default: false
    t.string   "logo_url",                limit: 255
    t.string   "iptc_categories",         limit: 255
    t.text     "concepts",                limit: 65535
    t.text     "summaries",               limit: 65535
    t.text     "hashtags",                limit: 65535
    t.integer  "characters_count",        limit: 4,     default: 0
    t.integer  "words_count",             limit: 4,     default: 0
    t.integer  "sentences_count",         limit: 4,     default: 0
    t.integer  "paragraphs_count",        limit: 4,     default: 0
    t.integer  "adverbs_count",           limit: 4,     default: 0
    t.integer  "adjectives_count",        limit: 4,     default: 0
    t.integer  "nouns_count",             limit: 4,     default: 0
    t.integer  "organizations_count",     limit: 4,     default: 0
    t.integer  "places_count",            limit: 4,     default: 0
    t.integer  "people_count",            limit: 4,     default: 0
    t.string   "slug",                    limit: 255
    t.string   "thumbnail",               limit: 255
    t.datetime "published_at"
    t.boolean  "myprgenie",               limit: 1,     default: false
    t.boolean  "accesswire",              limit: 1,     default: false
    t.boolean  "prnewswire",              limit: 1,     default: false
    t.datetime "myprgenie_published_at"
    t.datetime "accesswire_published_at"
    t.datetime "prnewswire_published_at"
    t.string   "boson_categories",        limit: 255
    t.string   "campaign_name",           limit: 255
  end

  add_index "releases", ["slug"], name: "index_releases_on_slug", using: :btree

  create_table "stastic_data", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "total_kols_count",         limit: 4
    t.integer  "incr_kols_count",          limit: 4
    t.integer  "total_campaigns_count",    limit: 4
    t.integer  "incr_campaigns_count",     limit: 4
    t.integer  "weibo_kols_count",         limit: 4
    t.integer  "incr_weibo_kols_count",    limit: 4
    t.integer  "weixin_kols_count",        limit: 4
    t.integer  "incr_weixin_kols_count",   limit: 4
    t.integer  "wx_third_kols_count",      limit: 4
    t.integer  "incr_wx_third_kols_count", limit: 4
    t.integer  "sign_up_kols_count",       limit: 4
    t.integer  "incr_sign_up_kols_count",  limit: 4
    t.text     "from_which_campaign",      limit: 65535
    t.boolean  "is_dealed",                limit: 1,     default: false
  end

  create_table "streams", force: :cascade do |t|
    t.integer  "user_id",            limit: 4,     null: false
    t.string   "name",               limit: 255
    t.text     "topics",             limit: 65535
    t.text     "blogs",              limit: 65535
    t.string   "sort_column",        limit: 255
    t.integer  "position",           limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "published_at",       limit: 255
    t.text     "keywords",           limit: 65535
    t.datetime "last_seen_story_at"
  end

  add_index "streams", ["last_seen_story_at"], name: "index_streams_on_last_seen_story_at", using: :btree
  add_index "streams", ["user_id"], name: "index_streams_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "label",      limit: 255
    t.integer  "position",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "cover_url",  limit: 255
  end

  create_table "test_emails", force: :cascade do |t|
    t.integer  "draft_pitch_id", limit: 4
    t.string   "emails",         limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "account_id",    limit: 4
    t.string   "account_type",  limit: 255
    t.integer  "item_id",       limit: 4
    t.string   "item_type",     limit: 255
    t.string   "direct",        limit: 255
    t.string   "subject",       limit: 255
    t.decimal  "credits",                   precision: 8, scale: 2
    t.decimal  "amount",                    precision: 8, scale: 2
    t.decimal  "avail_amount",              precision: 8, scale: 2
    t.decimal  "frozen_amount",             precision: 8, scale: 2
    t.integer  "opposite_id",   limit: 4
    t.string   "opposite_type", limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  create_table "unsubscribe_emails", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "email",      limit: 255
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

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,                          default: "",    null: false
    t.string   "encrypted_password",     limit: 255,                          default: ""
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,                            default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "name",                   limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "company",                limit: 255
    t.string   "time_zone",              limit: 255
    t.string   "invitation_token",       limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",       limit: 4
    t.integer  "invited_by_id",          limit: 4
    t.string   "invited_by_type",        limit: 255
    t.boolean  "is_primary",             limit: 1,                            default: true
    t.string   "avatar_url",             limit: 255
    t.string   "slug",                   limit: 255
    t.string   "locale",                 limit: 255
    t.decimal  "amount",                             precision: 12, scale: 2, default: 100.0
    t.decimal  "frozen_amount",                      precision: 12, scale: 2, default: 0.0
    t.string   "mobile_number",          limit: 255
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
    t.text     "status",          limit: 65535
    t.text     "claim_reason",    limit: 65535
    t.text     "campaign_name",   limit: 65535
    t.text     "company_name",    limit: 65535
    t.integer  "article_id",      limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
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
    t.string   "status",        limit: 255, default: "pending"
    t.string   "remark",        limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_foreign_key "weibo_invites", "campaigns"
  add_foreign_key "weibo_invites", "weibos"
end
