# class AddMissingIndexes < ActiveRecord::Migration
#   def change
#     ### add_index :addresses, [:addressable_id, :addressable_type], name: 'i_addr_on_addrable_id_type'
#
#     # add_index :admin_users_admin_roles, :admin_user_id
#     # add_index :agent_kols, :agent_id
#     # add_index :agent_kols, :kol_id
#     # add_index :agent_kols, :agent_id
#     # add_index :alipay_orders, :user_id
#     # add_index :article_contents, :article_category_id
#     # add_index :campaign_action_urls, :campaign_id
#     # add_index :campaign_actions, :campaign_id
#     # add_index :campaign_actions, :kol_id
#     # add_index :campaign_applies, :campaign_id
#     # add_index :campaign_applies, :kol_id
#     # add_index :campaign_invites, :campaign_apply_id
#     # add_index :campaign_materials, :campaign_id
#     # add_index :campaign_push_records, :campaign_id
#     # add_index :campaigns, :release_id
#     # add_index :cities, :province_id
#     # add_index :cps_article_materials, :cps_material_id
#     # add_index :cps_articles, :kol_id
#     # add_index :cps_promotion_order_items, :cps_promotion_order_id
#
#     ### add_index :cps_promotion_order_items, :ware_id
#
#     # add_index :cps_promotion_orders, :cps_article_share_id
#     # add_index :cps_promotion_orders, :kol_id
#
#     ### add_index :cps_promotion_orders, [:cps_article_share_id, :cps_promotion_order_item_id]
#
#     # add_index :districts, :city_id
#     # add_index :download_invitations, :inviter_id
#     # add_index :feedbacks, :kol_id
#     # add_index :helper_docs, :helper_tag_id
#     # add_index :identities, :user_id
#
#     ### add_index :images, [:referable_id, :referable_type]
#
#
#     # PRODUCTION
#     add_index :interested_campaigns, :campaign_id
#     add_index :interested_campaigns, :kol_id
#     add_index :interested_campaigns, :user_id
#     add_index :invoice_histories, :user_id
#     add_index :invoice_receivers, :user_id
#     add_index :invoices, :user_id
#     add_index :kol_categories, :identity_id
#     add_index :kol_influence_values, :kol_id
#     add_index :kol_profile_screens, :kol_id
#     add_index :kol_shows, :kol_id
#     add_index :kols_lists, :user_id
#     add_index :kols_lists_contacts, :kols_lists_id
#     add_index :lottery_activities, :lottery_product_id
#     add_index :lottery_activities, :lucky_kol_id
#     add_index :lottery_activity_orders, [:lottery_activity_id, :lottery_activity_ticket_id]
#     add_index :messages, [:item_id, :item_type]
#     add_index :messages, [:receiver_id, :receiver_type]
#     add_index :oauth_access_grants, :application_id
#     add_index :oauth_access_tokens, :application_id
#     add_index :oauth_access_tokens, [:doorkeeper/application_id, :doorkeeper/application_id]
#     add_index :payments, :discount_id
#     add_index :payments, :product_id
#     add_index :payments, :user_product_id
#     add_index :pictures, [:id, :type]
#     add_index :pictures, [:imageable_id, :imageable_type]
#     add_index :push_messages, [:item_id, :item_type]
#     add_index :recharge_records, :admin_user_id
#     add_index :sms_messages, :admin_user_id
#     add_index :social_account_tags, :kol_id
#     add_index :social_accounts, :kol_id
#     add_index :task_records, :invitees_id
#     add_index :task_records, :task_type
#     add_index :test_emails, :draft_pitch_id
#     add_index :transactions, [:account_id, :account_type]
#     add_index :transactions, [:item_id, :item_type]
#     add_index :transactions, [:opposite_id, :opposite_type]
#     add_index :users, :kol_id
#     add_index :users, :seller_id
#     add_index :users, [:invited_by_id, :invited_by_type]
#     add_index :wechat_article_performances, [:sender_id, :sender_type]
#     add_index :withdraws, :kol_id
#     add_index :withdraws, :user_id
#   end
# end
