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

  member_action :show_recharge, :method=>:get
  member_action :recharge, :method=>:post

  controller do
    def show_recharge
      @user = User.find(params[:id])
    end

    def recharge
      @user = User.find(params[:id])
      if params[:operate_type] == 'manual_recharge'
        @user.payout(params[:credits].to_f, params[:operate_type])
      else
        @user.income(params[:credits].to_f, params[:operate_type])
      end
      redirect_to '/admin/users'
    end
  end

  index do |user|
    id_column
    column "name" do |resource|
      "#{resource.first_name}  #{resource.last_name}"
    end
    column :email
    column :created_at
    column "avail amount" do |my_resource|
      my_resource.avail_amount
    end
    actions do |user|
      link_to 'Open Dashboard ', login_to_dashboard_admin_user_path(user.id), :method => :get, :target => "_blank" if current_admin_user.is_super_admin?
      link_to '充值/提现', show_recharge_admin_user_path(user.id), :method => :get, :target => "_blank" if current_admin_user.is_super_admin?
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
