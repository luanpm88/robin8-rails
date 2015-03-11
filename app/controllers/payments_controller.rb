class PaymentsController < ApplicationController

  before_action :authenticate_user!

  def index
    @payments = current_user.payments
    render json: @payments
  end

end