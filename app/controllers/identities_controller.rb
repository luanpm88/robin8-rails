class IdentitiesController < ApplicationController
  def current_categories
    categories = []
    if kol_signed_in?
      @identity = Identity.find params[:id]
      categories = @identity.iptc_categories.map { |c| {:id => c.id, :text => c.label} }
    end
    render :json => categories
  end

  def update
    @idientity = Identity.find params[:id]
    @idientity.attributes = identity_params
    categories = params[:identity][:interests]
    categories = '' if categories == nil
    categories = categories.strip.split(',').map {|s| s.strip}.uniq
    @categories = IptcCategory.where :id => categories
    if @idientity.valid?
      @idientity.iptc_categories = @categories
      @idientity.save
      render :json => {:result => "ok"}
    else
      render :json => {:result => "fail", :error_message => @kol.errors.full_messages }
    end
  end

  def show
    @identity = Identity.find params[:id]
    render :json => @identity
  end

  def destroy
    @identity = Identity.find params[:id]       rescue nil
    if @identity && @identity.destroy
      render :json => {:result => 'ok', :newest_identities => current_kol.identities }
    else
      render :json => {:result => "fail", :error_message => "not found!"}
    end
  end

  private
  def identity_params
    params.require(:identity).permit(:audience_age_groups, :audience_gender_ratio, :audience_regions,
      :edit_forward, :origin_publish, :forward, :origin_comment, :partake_activity, :panel_discussion,
      :undertake_activity, :undertake_activity, :image_speak, :give_speech)
  end


end