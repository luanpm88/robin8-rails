ActiveAdmin.register Kol do

  permit_params :email, :first_name, :last_name, :mobile_number, :gender

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

  member_action :show_recharge, :method => :get do

  end

  member_action :recharge, :method => :post do

  end

  controller do
    def show_recharge
      @kol = Kol.find(params[:id])
    end

    def recharge
      @kol = Kol.find(params[:id])
      if params[:operate_type] == 'manual_recharge'
        @kol.income(params[:credits].to_f, params[:operate_type])
      else
        @kol.payout(params[:credits].to_f, params[:operate_type])
      end
      redirect_to '/admin/kols'
    end
  end


  index do
    selectable_column
    id_column
    column :email
    column :social_name
    column :first_name
    column :last_name
    column :mobile_number
    column "avail amount" do |my_resource|
      my_resource.avail_amount
    end
    actions do |kol|
      link_to '充值/提现', show_recharge_admin_kol_path(kol.id), :method => :get, :target => "_blank" if current_admin_user.is_super_admin?
    end
  end

  form do |f|
    f.inputs "Post" do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :mobile_number
      f.input :gender
    end
    f.actions
  end

  filter :email
  filter :mobile_number
  filter :social_name

end
