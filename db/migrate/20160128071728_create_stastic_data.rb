class CreateStasticData < ActiveRecord::Migration
  def change
    create_table :stastic_data do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer  :total_kols_count
      t.integer  :incr_kols_count

      t.integer  :total_campaigns_count
      t.integer  :incr_campaigns_count

      t.integer  :weibo_kols_count
      t.integer  :incr_weibo_kols_count

      t.integer  :weixin_kols_count
      t.integer  :incr_weixin_kols_count

      t.integer  :wx_third_kols_count
      t.integer  :incr_wx_third_kols_count

      t.integer  :sign_up_kols_count
      t.integer  :incr_sign_up_kols_count

      t.text     :from_which_campaign
      t.boolean  :is_dealed, :default => false
    end
  end
end
