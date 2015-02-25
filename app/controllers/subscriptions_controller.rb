class SubscriptionsController < ApplicationController
  skip_before_filter :require_active_subscription
  layout false

  #before_filter :force_ssl

  before_filter :require_package ,:only=>[:new,:create]

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
            shopper_id: resp["batch_order"]["shopper"]["shopper_info"]["shopper_id"],
            recurring_amount: @package.price,
            charged_amount: @package.price,
            total_amount: @package.price,
            next_charge_date: Date.today + @package.interval.days
        )

        Payment.create!(
            subscription_id: @subscription.id,
            package_id: @package.id,
            total_amount: @package.price,
            charged_amount: @package.price,
            user_id: current_user.id,
            order_id: resp["batch_order"]["order"]["order_id"], #to be moved to httparty
            card_last_four_digits: resp["batch_order"]["order"]["post_sale_info"]["invoices"]["invoice"]["financial_transactions"]["financial_transaction"]["credit_card"]["card_last_four_digits"],
            card_type:    resp["batch_order"]["order"]["post_sale_info"]["invoices"]["invoice"]["financial_transactions"]["financial_transaction"]["credit_card"]["card_type"],
            expiration_year:   resp["batch_order"]["order"]["post_sale_info"]["invoices"]["invoice"]["financial_transactions"]["financial_transaction"]["credit_card"]["expiration_year"],
            expiration_month:    resp["batch_order"]["order"]["post_sale_info"]["invoices"]["invoice"]["financial_transactions"]["financial_transaction"]["credit_card"]["expiration_month"]
        )
      rescue Exception=> ex
        flash[:errors] = ["We are sorry, something is not right. Please fill in all details and try again"]
      end
    else
      flash[:errors] = errors
    end
    redirect_to :back
  end

  def edit #upgrade downgrade

  end

  def update

  end

  def destroy #to cancel account

  end


  def require_package
    @package = Package.last
  end

end