class BrandController < ApplicationController
  layout 'brand'
  def index
    @brand_home_props = { brand: current_user }
    unless current_user
      sign_in User.first
    end
  end

  def qiniu
    render json: { uptoken: Qiniu::Auth.generate_uptoken({
      scope: Rails.application.secrets.qiniu[:bucket],
      deadline: (Time.zone.now + 1.hours).to_i,
      returnBody: '{
        "name": $(fname),
        "size": $(fsize),
        "w": $(imageInfo.width),
        "h": $(imageInfo.height),
        "hash": $(etag)
      }'
    }) }
  end
end
