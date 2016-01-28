# encoding: utf-8

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

  collection_action :download_report, :method => :get do
    kols = Kol.all
      csv = CSV.generate() do |csv|
      # add headers
      # add data
      attributes = kols.first.attributes.keys()
      csv << attributes
      kols.each do |kol|
        values = []
        attributes.each do |key|
          value = kol.send(key)
          if value.is_a? String
            [/[\u{1f300}-\u{1f5ff}]/,  /[\u{2500}-\u{2BEF}]/, /[\u{1f600}-\u{1f64f}]/, /[\u{2702}-\u{27b0}]/].each do |filter|
              value = value.gsub(filter, "?")
            end
          end
          values << value
        end
        csv << [kol.last_name]
      end
    end
    # send file to user
    send_data csv, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=report.csv"
  end

  collection_action :stastic_data, :method => :get do
    @stastic_data = StasticData.new
  end

   ActiveAdmin.setup do |config|
    # Want PDF added to default download links
      config.download_links = []
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
