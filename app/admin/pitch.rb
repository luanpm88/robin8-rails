ActiveAdmin.register Pitch do

  permit_params :user_id , :release_id, :twitter_pitch, :email_pitch, :summary_length,
                :email_address, :email_subject, :email_targets, :twitter_targets

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