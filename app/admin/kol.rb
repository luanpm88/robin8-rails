ActiveAdmin.register Kol do
  actions :all, :except => [:destroy]

  permit_params :email, :first_name, :last_name, :mobile_number, :gender, :forbid_campaign_time, :five_click_threshold,
                :total_click_threshold

  member_action :show_recharge, :method => :get
  member_action :recharge, :method => :post

  controller do
    def show_recharge
      @kol = Kol.find(params[:id])
    end

    def recharge
      @kol = Kol.find(params[:id])
      if params[:operate_type] == 'manual_recharge'
        @kol.income(params[:credits].to_f, params[:operate_type])
      else
        @kol.payout(params[:credits].to_f, params[:operate_type])
      end
      redirect_to '/admin/kols'
    end
  end


  index do
    selectable_column
    id_column
    column :email
    column :social_name
    column "name" do |resource|
      "#{resource.first_name}  #{resource.last_name}"
    end
    column :mobile_number
    column :province
    column "avail amount" do |my_resource|
      my_resource.avail_amount
    end
    column "Source", :from_which_campaign
    column "forbid campaign time"   do |resource|
      resource.forbid_campaign_time.to_s(:all_time)  rescue nil
    end
    column :five_click_threshold
    column :total_click_threshold
    actions do |kol|
      link_to '充值/提现', show_recharge_admin_kol_path(kol.id), :method => :get, :target => "_blank" if current_admin_user.is_super_admin?
    end
  end

  form do |f|
    f.inputs "Post" do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :mobile_number
      f.input :gender
      f.input :forbid_campaign_time
      f.input :five_click_threshold
      f.input :total_click_threshold
    end
    f.actions
  end

  filter :email
  filter :mobile_number
  filter :social_name
  filter :first_name
  filter :last_name
  filter :province
  filter :from_which_campaign, label: 'source', as: :select
  filter :forbid_campaign_time
  filter :five_click_threshold
  filter :total_click_threshold
end
