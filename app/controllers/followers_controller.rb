class FollowersController < ApplicationController
  
  def add
    RestClient.post("#{url}lists/test@mg.robin8.com/members", email: params[:email])
  end
  
  private

    def url
      url ||= "https://api:#{Rails.application.secrets.mailgun[:api_key]}@api.mailgun.net/v2/"
    end

end
