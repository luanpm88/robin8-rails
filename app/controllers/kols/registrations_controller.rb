module Kols
  class RegistrationsController < Devise::RegistrationsController
    respond_to :html, :json

    def update
      categories = params[:kol][:interests]
      categories = '' if categories == nil
      categories = categories.strip.split(',').map {|s| s.strip}.uniq
      categories = IptcCategory.unscoped.cn.where :id => categories
      resource.iptc_categories = categories
      super
    end

    protected

    def update_resource(resource, params)
      if params[:password]=="" && params[:password_confirmation]==""
        params.delete(:current_password)
        resource.update_without_password(params)
      else
        resource.update_with_password(params)
      end
    end

  end
end
