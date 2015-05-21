ActiveAdmin.register User do

  menu :priority => 4, :label => "Users" ,:if => proc { current_admin_user.is_super_admin? }

  permit_params :email , :password, :encrypted_password

  filter :id
  filter :first_name
  filter :last_name
  filter :email
  filter :last_sign_in_at

  index do |user|
    id_column
    column :first_name
    column :last_name
    column :email
    column :created_at
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :remember_created_at
      f.input :confirmed_at
      f.input :name
      f.input :first_name
      f.input :last_name
      f.input :company
      f.input :time_zone
      f.input :invitation_limit
      f.input :invited_by_type
      f.input :is_primary
      f.input :avatar_url
    end
    f.actions
  end


end
