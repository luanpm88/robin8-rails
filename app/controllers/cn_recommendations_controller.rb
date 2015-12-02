class CnRecommendationsController < ApplicationController
  def index
    begin
      page = params[:page].to_i
      page = page >= 1 ? page : 1

      url = File.join(Rails.application.secrets.cn_recommendation_url, page.to_s) + "?labels=#{get_labels.join(",")}"

      response = RestClient::Request.execute(method: :get, url: url,
                            timeout: 10)
      render  :json => (JSON.parse response)["articles"]
   rescue Exception => e
      render :json => []
   end
  end

  private
  def get_labels
    return default_labels unless current_kol
    %w(wechat wechat_third weibo).each do |item|
      current_kol.identities.where(:provider => item).each do |identity|
        if identity.present? and identity.iptc_categories.present?
          return identity.iptc_categories.map(&:name)
        end
      end
    end
    return default_labels
  end

  def default_labels
    ["finance", "digitcamera", "dish", "computer"]
  end
end
