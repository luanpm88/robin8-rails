class ChangeDefaultValuesOfTables < ActiveRecord::Migration
  def change
    change_column_default :admin_users, :sign_in_count, 0
    change_column_default :admin_users, :is_super_admin, false
    
    change_column_default :alipay_orders, :status, "pending"
    change_column_default :alipay_orders, :tax,  0.0
    change_column_default :alipay_orders, :need_invoice, false

    change_column_default :announcements, :display, false
    change_column_default :announcements, :position, 0

    change_column_default :article_actions, :look, false
    change_column_default :article_actions, :forward, false
    change_column_default :article_actions, :collect, false
    change_column_default :article_actions, :like, false

    change_column_default :campaign_invites, :total_click, 0
    change_column_default :campaign_invites, :avail_click, 0
    change_column_default :campaign_invites, :is_invited,  false
    change_column_default :campaign_invites, :share_count, 0
    change_column_default :campaign_invites, :observer_status, 0
    change_column_default :campaign_invites, :auto_check, false

    change_column_default :campaigns, :non_cash, false
    change_column_default :campaigns, :avail_click, 0
    change_column_default :campaigns, :total_click, 0
    change_column_default :campaigns, :hide_brand_name, false
    change_column_default :campaigns, :end_apply_check, false
    change_column_default :campaigns, :need_pay_amount, 0.0
    change_column_default :campaigns, :used_voucher, false
    change_column_default :campaigns, :voucher_amount, 0.0
    change_column_default :campaigns, :alipay_status, 0
    change_column_default :campaigns, :campaign_from, 'pc'
    change_column_default :campaigns, :budget_editable, true

    change_column_default :contacts, :origin, 0

    change_column_default :cpi_regs, :status, "pending"

    change_column_default :discounts, :is_active, true
    change_column_default :discounts, :is_recurring, false

    change_column_default :download_invitations, :effective, false

    change_column_default :features, :is_active, true
    change_column_default :feedbacks, :status, "pending"
    change_column_default :helper_docs, :sort_weight, 100

    change_column_default :identities, :has_grabed, false
    change_column_default :identities, :verified, false

    change_column_default :invoice_histories, :status, "pending"
    change_column_default :invoices, :invoice_type, "common"

    change_column_default :kol_announcements, :enable, true

    change_column_default :kol_contacts, :exist, false
    change_column_default :kol_contacts, :invite_status, false


    change_column_default :kol_influence_values, :share_times, 0
    change_column_default :kol_influence_values, :read_times,  0
    change_column_default :kol_influence_values, :base_score, 500
    change_column_default :kol_influence_values, :follower_score, 0
    change_column_default :kol_influence_values, :status_score, 0
    change_column_default :kol_influence_values, :register_score, 0
    change_column_default :kol_influence_values, :verify_score, 0
    change_column_default :kol_influence_values, :campaign_total_click_score, 0
    change_column_default :kol_influence_values, :campaign_avg_click_score, 0
    change_column_default :kol_influence_values, :article_total_click_score, 0
    change_column_default :kol_influence_values, :article_avg_click_score, 0

    change_column_default :kols, :sign_in_count, 0
    change_column_default :kols, :is_public, true
    change_column_default :kols, :gender, 0
    change_column_default :kols, :stats_total, 0
    change_column_default :kols, :amount, 0
    change_column_default :kols, :frozen_amount, 0
    change_column_default :kols, :influence_score, -1
    change_column_default :kols, :kol_role, "public"
    change_column_default :kols, :role_apply_status, "pending"
    change_column_default :kols, :is_hot, 0

    change_column_default :lottery_activities, :status, "pending"
    change_column_default :lottery_activities, :delivered, false

    change_column_default :lottery_activity_orders, :number, 0
    change_column_default :lottery_activity_orders, :status, "pending"


    change_column_default :lottery_products, :quantity, 1
    change_column_default :lottery_products, :price, 0


    change_column_default :messages, :is_read, false
    change_column_default :oauth_applications, :union, false

    change_column_default :push_messages, :is_offline, true
    change_column_default :push_messages, :offline_expire_time, 43200000

    change_column_default :releases, :is_private, false
    change_column_default :releases, :characters_count, 0
    change_column_default :releases, :words_count, 0
    change_column_default :releases, :sentences_count, 0
    change_column_default :releases, :paragraphs_count, 0
    change_column_default :releases, :adverbs_count, 0
    change_column_default :releases, :adjectives_count, 0
    change_column_default :releases, :nouns_count, 0
    change_column_default :releases, :organizations_count, 0
    change_column_default :releases, :places_count, 0
    change_column_default :releases, :people_count, 0

    change_column_default :reward_tasks, :enable, true

    change_column_default :social_accounts, :verified, false
    change_column_default :stastic_data, :is_dealed, false

    change_column_default :tags, :enabled, true

    change_column_default :task_records, :status, :pending

    change_column_default :tmp_identities, :has_grabed, false
    change_column_default :tmp_identities, :verified, false

    change_column_default :tmp_kol_contacts, :exist, false
    change_column_default :tmp_kol_contacts, :invite_status, false

    change_column_default :track_urls, :click_count, 0
    change_column_default :transactions, :tax, 0.0

    change_column_default :users, :sign_in_count, 0
    change_column_default :users, :is_primary, true
    change_column_default :users, :amount, 0.0
    change_column_default :users, :frozen_amount, 0.0
    change_column_default :users, :appliable_credits, 0.0
    change_column_default :users, :is_active, true
  end
end
