ActiveAdmin.register Campaign do

  permit_params :name, :description, :deadline, :budget, :user_id
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
    id_column
    column :name
    column "Advertiser" do |my_resource|
      my_resource.user.name
    end
    column "Created time", :created_at
    column "Start time", :start_time
    column "End time", :deadline
    column :budget
    column "Spent" do |my_resource|
      my_resource.get_fee_info.split('/').first
    end
    column "Actual Clicks",  :avail_click
    column "CPC", :per_click_budget
    actions
  end
end
