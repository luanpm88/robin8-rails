ActiveAdmin.register Campaign do

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
    column "Actual Clicks" do |my_resource|
      my_resource.get_avail_click
    end
    column "CPC", :per_click_budget
    actions
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
end
