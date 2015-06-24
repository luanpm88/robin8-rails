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
        render :new, :layout => "website"
      end
    else
      @kol = Kol.new
      render :new, :layout => "website"
    end
  end

  def suggest_categories
    filter = params[:f]
    filter = "" if filter == nil
    categories = IptcCategory.starts_with(filter).limit(10).map { |c| {:id => c.id, :text => c.label} }
    render :json => categories
  end

  def current_categories
    categories = []
    if kol_signed_in?
      categories = current_kol.iptc_categories.map { |c| {:id => c.id, :text => c.label} }
    end
    render :json => categories
  end

  private

  def kol_params
    params.require(:kol).permit(:first_name,:last_name,:email,:password,:location,:bank_account,:interests)
  end

end


