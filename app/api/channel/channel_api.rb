module Channel
	class ChannelApi < Grape::API
	  format :json
	  prefix :partner_campaign
	  before do
	     # return true unless params[:channel_id] == "wcs" # WCS 微差事加密而已
	    if params[:channel_id] == "wcs"
		    key       = "k4B9Uif81T3Y"
		    data      = "channel_id=#{params[:channel_id]}&nonce=#{params[:nonce]}&timestamp=#{params[:timestamp]}"
		    digest    = OpenSSL::Digest.new('sha1')
		    hmac      = OpenSSL::HMAC.hexdigest(digest, key, data)
		    unless hmac == params[:signature]
		      Rails.logger.partner_campaign.info "--check-error: #{params}"
		      error!({ error: '验证失败' }, 404)
		    end
		end
	  end

	  get :get_campaign do
	  	campaign = Campaign.where(channel: ['all' , params[:channel_id]])
	  	present :status, 200
	  	present :data, campaign, with: Channel::Entities::CampaignEntities::Campaign
	  end
	end
end