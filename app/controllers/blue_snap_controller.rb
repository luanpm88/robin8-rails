class BlueSnapController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def new

  end

  def create

  end

  def change_card_info
    render :layout => "website"
  end

  def card_update_confirmation
    render :layout => "website"
  end

  def update_card_info
    errors,resp = BlueSnap::Shopper.update_credit_card(request, current_user, params, current_user.active_subscription.bluesnap_shopper_id)
    if errors.blank?
      return redirect_to "/card-update-confirmation"
    else
      flash.now[:errors] = errors
      render :change_card_info, :layout => "website"
    end
  end

end