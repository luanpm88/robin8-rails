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
    name =  params[:name]
    location = params[:location] if not params[:location].blank?
    kols = Kol.joins("LEFT JOIN private_kols ON kols.id = private_kols.kol_id").where("private_kols.user_id = ? or kols.is_public = ?", current_user.id, 1)
    if not categories.blank?
      kols = kols.includes(:iptc_categories).where :kol_categories => { :iptc_category_id => categories }
    end
    if (not name.blank?)
      kols = kols.where('kols.first_name LIKE ? OR kols.last_name like ?', "%#{name}%", "%#{name}%")
    end
    if (not location.blank?)
      kols = kols.where :location => location
    end
    render :json => kols.to_json(:methods => [:categories])
  end

  private

  def kol_params
    params.require(:kol).permit(:first_name,:last_name,:email,:password,:location,:is_public,:bank_account,:interests)
  end

end


