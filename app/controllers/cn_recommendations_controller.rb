class CnRecommendationsController < ApplicationController
  def index
    begin
      page = params[:page].to_i
      page = page >= 1 ? page : 1
      url = File.join(Rails.application.secrets.cn_recommendation_url, page.to_s) + "?labels=finance,digitcamera,dish,computer"

      response = RestClient::Request.execute(method: :get, url: url,
                            timeout: 10)
      render  :json => (JSON.parse response)["articles"]
   rescue Exception => e
      render :json => []
   end
  end
end