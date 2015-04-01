ActiveAdmin.register User do

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
