class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  skip_before_filter :require_active_subscription
  layout false
  #before_filter :force_ssl

  before_filter :require_package ,:only => [:new,:create,:edit,:update]
  before_filter :validate_upgrade,:only => [:edit,:update]
  before_filter :validate_subsription,:only=>[:new]

  def new
    @subscription = Subscription.new
  end

  def create
    errors,resp = BlueSnap::Shopper.new(request, current_user, params, @package)
    if errors.blank?
      begin
        @subscription = Subscription.create!(
            package_id: @package.id,
            user_id: current_user.id,
            bluesnap_shopper_id: resp[:batch_order][:shopper][:shopper_info][:shopper_id],
            recurring_amount: @package.price,
            next_charge_date: nil # to be set by invoice generation
        )
        p @subscription
        flash[:success]  = "Subscribed Sucessfully" #take to any page as required
      rescue Exception=> ex
        p ex
        flash[:errors] = ["We are sorry, something is not right. Please contact support for more details."]
      end
    else
      p errors
      flash[:errors] = errors
    end
    redirect_to :pricing
  end

  def edit #upgrade downgrade
    @subscription = current_user.active_subscription
  end

  def update
    flash[:errors],resp = BlueSnap::Subscription.update(current_user.active_subscription.bluesnap_subscription_id,current_user.active_subscription.bluesnap_shopper_id, @package.sku_id)
    if flash[:errors].blank?
      @subscription = current_user.active_subscription.update_attributes(
          package_id: @package.id,
          recurring_amount: @package.price
      )
      flash[:success] = "Your package has been changed" # take to any page as required.
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


  def index
    @subscription = current_user.active_subscription
  end


  private

  def require_package
    @package = Package.where(slug: params[:slug]).last
    redirect_to :pricing if @package.blank?
  end

  def validate_upgrade
    @package = Package.where(slug: params[:slug]).last
    if @package.id == current_user.active_subscription.package_id
      flash[:error] = "You are already subscribed to this package"
      return redirect_to :back
    end
  end

  def validate_subsription
    return redirect_to :back if current_user.active_subscription.present?
  end

end