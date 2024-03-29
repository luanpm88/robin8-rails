ActiveAdmin.register Campaign do

  actions :all, :except => [:destroy]

  member_action :unagree, :method => :put
  member_action :agree, :method => :put
  member_action :show_action_urls, :method => :get

  controller do
    before_filter :set_admin_to_cookie, only: [:index]

    def set_admin_to_cookie
      cookies[:admin] = true
    end

    def scoped_collection
      Campaign.includes(:user)
    end

    def unagree
    end

    def agree
      campaign = Campaign.find params[:id]
      campaign.update(:status => :agreed)
      redirect_to admin_campaigns_path
    end

    def show_action_urls
      campaign = Campaign.find params[:id]
      @campaign_action_urls = campaign.campaign_action_urls
    end
  end

  permit_params :name, :start_time, :deadline, :per_action_budget, :description, :url, :message, :img_url
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end



  index do
    selectable_column
    id_column
    column :name
    column :user_id
    column "user email", :email
    column "Advertiser" do |my_resource|
      my_resource.user.name                   rescue nil
    end

    column "Start time" do |my_resource|
      my_resource.start_time.to_s(:all_time)     rescue my_resource.start_time
    end

    column "End time" do |my_resource|
      my_resource.deadline.to_s(:all_time)       rescue my_resource.deadline
    end

    column :budget
    column :status
    column "mode" do |my_resource|
      if my_resource.per_budget_type == "click"
        'Per click'
      elsif my_resource.per_budget_type == "post"
        'Per post'
      else
        'cpa'
      end
    end
    column "Spent" do |my_resource|
      my_resource.take_budget
    end
    column "Actual Clicks" do |my_resource|
      my_resource.get_avail_click
    end
    column "点击计费/post 计费", :per_action_budget
    column "action_urls" do |my_resource|
      (link_to '查看', show_action_urls_admin_campaign_path(my_resource.id), :method => :get, :target => "_blank" )
    end
    actions do |my_resource|
      if my_resource.status == "unexecute"
        (link_to 'agree ', agree_admin_campaign_path(my_resource.id), :method => :put )
      else
        (link_to '统计 ', "/#smart_campaign/stats/#{my_resource.id}", :method => :get )
      end
    end
  end

  form do |f|
    f.inputs "Post" do
      f.input :name
      f.input :description
      f.input :url
      f.input :message
      f.input :img_url
      f.input :per_action_budget
      f.input :per_action_budget
      f.input :start_time
      f.input :deadline
    end
    f.actions
  end

  filter :name
  filter :user_name_cont, :as => :string,  label: 'advertiser name'
  filter :user_email_cont, :as => :string,  label: 'advertiser email'
end
