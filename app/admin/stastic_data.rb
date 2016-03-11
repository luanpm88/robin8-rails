ActiveAdmin.register StasticData do

  permit_params :start_time, :end_time
  index do
    column :start_time
    column :end_time
    column :total_kols_count
    column  :incr_kols_count

    column  :total_campaigns_count
    column  :incr_campaigns_count

    column  :weibo_kols_count
    column  :incr_weibo_kols_count

    column  :weixin_kols_count
    column  :incr_weixin_kols_count

    column  :wx_third_kols_count
    column  :incr_wx_third_kols_count

    column  :sign_up_kols_count
    column  :incr_sign_up_kols_count

    column  :from_which_campaign
    column  :is_dealed
  end
end
