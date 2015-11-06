class IdentitiesController < ApplicationController
  def current_categories
    categories = []
    if kol_signed_in?
      @identity = Identity.find params[:id]
      categories = @identity.iptc_categories.map { |c| {:id => c.id, :text => c.label} }
    end
    render :json => categories
  end

  def udpate
    @idientity = Identity.find params[:id]
    categories = params[:interests]
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

  private
  def identity_params
    params!
  end


end
