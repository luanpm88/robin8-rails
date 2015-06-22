class KolsController < ApplicationController

  def get_current_kol
    render json: current_kol
  end

  def create
    if request.post?
      @kol = Kol.new(kol_params)
      if @kol.valid?
        @kol.save
        sign_in @kol
        return redirect_to :root
      else
        flash.now[:errors] = @kol.errors.full_messages
      end
    else
      @kol = Kol.new
      render :new, :layout => "website"
    end
  end

  private

  def kol_params
    params.require(:kol).permit(:first_name,:last_name,:email,:password,:location,:bank_account,:interests)
  end

end


