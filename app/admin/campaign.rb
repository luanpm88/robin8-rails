ActiveAdmin.register Campaign do

  member_action :unagree, :method => :put
  member_action :agree, :method => :put
  controller do
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
  end

  permit_params :name, :budget, :start_time, :deadline
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
      my_resource.user.name
    end
    column "Created time", :created_at
    column "Start time", :start_time
    column "End time", :deadline
    column :budget
    column :status
    column "Spent" do |my_resource|
      my_resource.get_fee_info.split('/').first
    end
    column "Actual Clicks" do |my_resource|
      my_resource.get_avail_click
    end
    column "CPC", :per_click_budget
    actions do |my_resource|
      link_to '同意 ', agree_admin_campaign_path(my_resource.id), :method => :put if my_resource.status == "unexecute"
    end
  end

  form do |f|
    f.inputs "Post" do
      f.input :name
      f.input :budget
      f.input :start_time
      f.input :deadline
    end
    f.actions
  end

  filter :name
  filter :user_name_cont, :as => :string,  label: 'advertiser name'
  filter :user_email_cont, :as => :string,  label: 'advertiser email'
end
