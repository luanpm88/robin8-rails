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

end
