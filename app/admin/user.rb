ActiveAdmin.register User do

  menu :priority => 4, :label => "Users" ,:if => proc { current_admin_user.is_super_admin? }

  permit_params :email , :password, :encrypted_password

  filter :id
  filter :first_name
  filter :last_name
  filter :email
  filter :last_sign_in_at

  member_action :login_to_dashboard, method: :get do
    user = User.find(params[:id])
    return render :status => 404 if not current_admin_user.is_super_admin?
    sign_in user
    redirect_to "/"
  end

  index do |user|
    id_column
    column :first_name
    column :last_name
    column :email
    column :created_at
    actions do |user|
      link_to 'Open Dashboard ', login_to_dashboard_admin_user_path(user.id), :method => :get, :target => "_blank" if current_admin_user.is_super_admin?
    end
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
