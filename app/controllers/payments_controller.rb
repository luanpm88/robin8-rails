class PaymentsController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :validate_subscription
  #before_filter :force_ssl
  before_filter :require_package ,:only => [:new,:create,:edit,:update]
  # before_filter :validate_upgrade,:only => [:edit,:update]
  before_filter :validate_subscription,:only=>[:new]
  before_filter :validate_add_on_cancel,:only=>[:destroy_add_on]

  def apply_discount
    discount = Discount.active.where(code: params[:code]).last
    if discount.present?
      return render :text => discount.calculate(current_user,Package.where(slug: params[:product_slug]).first) if discount.is_global?
      return render :text => discount.calculate(current_user,Package.where(slug: params[:product_slug]).first) if discount.on_user_and_product?(current_user.id,params[:product_slug])
      return render :text => discount.calculate(current_user,Package.where(slug: params[:product_slug]).first) if discount.only_on_product?(params[:product_slug])
    end
    render :text => ""
  end

  def new
    @payment = Payment.new
    render :layout => "website"
  end

  def create
    errors,resp = BlueSnap::Shopper.new(request, current_user, params, @product,@add_ons,@add_on_hash)
    @payment = Payment.new
    if errors.blank?
      begin
        current_user.user_products.create!(
            product_id: @product.id,
            bluesnap_shopper_id: resp[:batch_order][:shopper][:shopper_info][:shopper_id],
            bluesnap_order_id: resp[:batch_order][:order][:order_id]
        ) if @product.present?

        @add_ons.each do |add_on|
          @add_on_hash["#{add_on.id}"].to_i.times{
            current_user.user_products.create!(product_id: add_on.id,
                                               bluesnap_shopper_id: resp[:batch_order][:shopper][:shopper_info][:shopper_id],
                                               bluesnap_order_id: resp[:batch_order][:order][:order_id])
          }
        end if @add_ons.present?
        UserMailer.add_ons_payment_confirmation(@add_ons,current_user,@add_on_hash).deliver if @add_ons.present?
      rescue Exception=> ex
        flash[:errors] = ["We are sorry, something is not right. Please contact support for more details."]
      end
      return redirect_to "/payment-confirmation"

    else
      flash.now[:errors] = errors
      render :new, :layout => "website"
    end
  end

  def create_subscription
    @package = Package.find(params[:package_id])
    errors,resp = BlueSnap::Shopper.new(request, current_user, params, @package)
    if errors.blank?
      begin
        @subscription = current_user.user_products.create!(
            package_id: @package.id,
            bluesnap_shopper_id: resp[:batch_order][:shopper][:shopper_info][:shopper_id],
            recurring_amount: @package.price,
            next_charge_date: nil # to be set by invoice generation
        )
        render json: {subscription: @subscription, message: 'Your package has been created'} , status: :ok
      rescue Exception => ex
        render json:["We are sorry, something is not right. Please contact support for more details."], status: :bad_request
      end
    else
      p errors
      render json: errors, status: :bad_request
    end
  end

  def update_subscription
    @package = Package.find(params[:package_id])
    errors,resp = BlueSnap::Subscription.update(current_user.active_subscription.bluesnap_subscription_id, current_user.active_subscription.bluesnap_shopper_id, @package.sku_id)
    if errors.blank?
      begin
        current_user.user_features.joins(:product).where(products: {is_package: true}).each do |user_feature|
          user_feature.update_attributes(available_count: 0, max_count: 0)
        end

        current_user.active_subscription.update_attributes(
            package_id: @package.id,
            recurring_amount: @package.price
        )
        render json: {subscription: current_user.active_subscription, message: 'Your package has been updated'} , status: :ok
      rescue Exception => ex
        render json: ["We are sorry, something is not right. Please contact support for more details."], status: :bad_request
      end
    else
      p errors
      render json: errors.responseJSON, status: :bad_request
    end
  end

  def destroy_subscription
    if current_user.active_subscription.present?
      if current_user.active_subscription.cancel!
        render json: current_user.to_json.html_safe, status: :ok
      else
        render json: ["We could not cancel your package at this time."], status: :bad_request
      end
    else
      render json: { message: "Your haven't active subscription" }, status: :ok
    end
  end

  def edit #upgrade downgrade
    @payment = current_user.active_subscription.payments.last
    render :layout => "website"
  end

  def update
    flash[:errors] = BlueSnap::Subscription.update(current_user.active_subscription.bluesnap_subscription_id,current_user.active_subscription.bluesnap_shopper_id, @product.sku_id,params[:code],current_user)
    if flash[:errors].blank?
      current_user.user_features.joins(:product).where(products: {is_package: true}).each do |user_feature|
        user_feature.update_attributes(available_count: 0, max_count: 0)
      end

      @subscription = current_user.active_subscription.update_attributes(
          product_id: @product.id,
          recurring_amount: @product.price
      )
      return redirect_to "/payment-confirmation"
    else
      redirect_to :back
    end

  end

  def destroy #to cancel account
    if current_user.active_subscription.present?
      if current_user.active_subscription.cancel!
        flash[:success] = "Your package has been cancelled"
      else
        flash[:error] = "We could not cancel your package at this time."
      end

    end
    redirect_to :back
  end

  def destroy_add_on
    if current_user.current_add_ons.present?
      if current_user.user_products.where(id: params[:id]).first.cancel!
        add_on = current_user.user_products.where(id: params[:id]).first.product
        feature =   current_user.user_features.where(product_id: add_on.id).first
        feature.update_attribute(:available_count,feature.available_count - 1)
        render json: current_user.to_json.html_safe, status: :ok
      else
        render :json => {error: "Something went wrong!"}, status: 422
      end
    end
  end

  def index
    @payments = current_user.payments
    render json: @payments
  end

  private

  def require_package
    @product = Package.where(slug: params[:slug]).last
    @discount = Discount.active.where(code: params[:code]).first if params[:code].present?
    if params[:add_ons]
      @add_on_hash = params[:add_ons]
      ids = []
      @add_on_hash.each{|k,v| ids << k if v.to_i > 0}
      @add_ons = AddOn.active.add_on.where(id: ids)
    end
    redirect_to :pricing if @product.blank? && @add_ons.blank?
  end

  def validate_upgrade
    @product = Package.where(slug: params[:slug]).last
    if current_user.active_subscription.present? && @product.id == current_user.active_subscription.product_id
      flash[:error] = "You are already subscribed to this package"
      return redirect_to :root
    end
  end

  def validate_subscription
    @product = Package.where(slug: params[:slug]).last
    return redirect_to "/upgrade/#{@product.slug}" if @product && current_user.active_subscription.present?
  end

  def authenticate_user!
    if user_signed_in?
      super
    else
      session[:redirect_checkout_url] = "/subscribe/#{params[:slug]}"
      flash[:info] = "Please signup below and continue"
      return redirect_to new_user_path
    end
  end

  def validate_add_on_cancel
    if current_user.current_add_ons.present?
      if current_user.user_products(id: params[:id]).exists?
        if current_user.can_cancel_add_on?(params[:id])
          return true
        else
          render :json => {error: "You can't cancel this add-on. Contact support for more details."}, status: 422
        end
      else
        render :json => {error: "No such add-on found"}, status: 422
      end
    end
  end


end