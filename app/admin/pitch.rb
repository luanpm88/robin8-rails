ActiveAdmin.register Pitch do


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
    column :twitter_pitch do |my_resource|
      truncate(my_resource.twitter_pitch, omision: "...", length: 40)
    end
    column :email_pitch do |my_resource|
      truncate(my_resource.email_pitch, omision: "...", length: 40)
    end
    column :summary_length
    column :email_address
    column :created_at
    column :updated_at
    column :email_subject
    column :email_targets
    column :twitter_targets
    actions
  end
end
