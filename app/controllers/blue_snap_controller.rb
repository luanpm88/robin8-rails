class BlueSnapController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def new

  end

  def create

  end

  def change_card_info
    render :layout => "website"
  end

  def change_campaign_card_info
    render :layout => "website"
  end

  def update_card_info
    errors,resp = BlueSnap::Shopper.update_credit_card(request, current_user, params, current_user.active_subscription.bluesnap_shopper_id, current_user.active_subscription.bluesnap_subscription_id)
    if errors.blank?
      return render :card_update_confirmation, :layout => "website"
    else
      render :card_update_error, :layout => "website"
    end
  end

  def update_campaign_card_info
    #errors,resp = BlueSnap::Shopper.update_credit_card(request, current_user, params, current_user.active_subscription.bluesnap_shopper_id, current_user.active_subscription.bluesnap_subscription_id)
    #if errors.blank?
    return render :card_update_confirmation, :layout => "website"
    #else
    #  render :card_update_error, :layout => "website"
    #end
  end

end
