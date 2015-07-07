class KolsController < ApplicationController

  def get_current_kol
    render json: current_kol
  end

  def create
    if request.post?
      @kol = Kol.new(kol_params)
      categories = params[:interests]
      categories = '' if categories == nil
      categories = categories.strip.split(',').map {|s| s.strip}.uniq
      @categories = IptcCategory.where :id => categories
      if @kol.valid?
        @kol.iptc_categories = @categories
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

  def suggest_kols
    kols = []
    categories = params[:categories]
    categories = categories.split(',') if not categories.blank?
    if not categories.blank?
      kols = Kol.joins(:iptc_categories).where :kol_categories => { :iptc_category_id => categories }
    end
    render :json => kols.to_json(:include => :iptc_categories)
  end

  private

  def kol_params
    params.require(:kol).permit(:first_name,:last_name,:email,:password,:location,:is_public,:bank_account,:interests)
  end

end


