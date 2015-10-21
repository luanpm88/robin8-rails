ActiveAdmin.register Discount do
  permit_params :code , :discount_name, :description,:percentage,:max_count,:is_recurring ,:expiry,user_discounts_attributes: [:id, :user_id, :discount_id, :_destroy],product_discounts_attributes: [:id, :discount_id, :product_id, :_destroy]

  member_action :activate, method: :put do
    d = Discount.find(params[:id])
    d.update_attribute(:is_active, true)
    redirect_to :back, notice: "Discount Activated. Expiry at :#{d.expiry}"
  end

  action_item only: :show do
    link_to('Activate', activate_admin_discount_path(discount), method: :put) if !discount.is_active?
  end

  member_action :deactivate, method: :put do
    d = Discount.find(params[:id])
    d.update_attribute(:is_active, false)
    redirect_to :back, notice: "Discount Deactivated."
  end

  action_item only: :show do
    link_to('Deactivate', deactivate_admin_discount_path(discount), method: :put) if discount.is_active?
  end

  form do |f|
    f.inputs "Discount" do
      f.input :code,:hint => "Match this code to Bluesnap Code exactly"
      f.input :discount_name
      f.input :description
      f.input :percentage, :hint => "How much % should be off"
      f.input :max_count,:hint => "How many times can it be redeemed?"
      f.input :expiry,:hint => "When to expire the the discount code?"
      f.input :is_recurring,:hint => "Will it be applied to recurring charges ?"
    end

    f.inputs "On Products * If left empty, will be available to all products" do
      f.has_many :product_discounts, :heading => 'Attach to a specific Product' do |cf|
        cf.input :product
        cf.input :_destroy, as: :boolean, label: "Delete?"
      end
    end

    f.inputs "To Users * If left empty, will be available to all users" do

      users = User.all.map do |u|
        if u.name?
          name = u.name
        elsif u.first_name? && u.last_name?
          name = "#{u.first_name} #{u.last_name}"
        end
        email = u.email? ? u.email : nil
        [name && email ? "#{name}, #{email}" : "#{name}#{email}", u.id]
      end

      f.has_many :user_discounts, :heading => 'Attach to a specific User Only' do |cf|
        cf.input :user, :label => 'User', :as => :select, :collection => users
        cf.input :_destroy, as: :boolean, label: "Delete?"
      end
    end

    f.actions
  end

  index do |d|
    id_column
    column :code
    column :discount_name
    column :percentage
    column :expiry
    column :created_at
    actions
  end

end
