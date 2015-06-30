require 'httparty'

class WriplTweetAnalysisWorker
  include Sidekiq::Worker

  def perform(user_id) 
    
    identity = Identity.where("user_id = #{user_id} AND provider = 'twitter'").first

    unless identity.blank?
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.twitter[:api_key]
        config.consumer_secret     = Rails.application.secrets.twitter[:api_secret]
        config.access_token        = identity.token
        config.access_token_secret = identity.token_secret
      end
    end

    tweets = client.user_timeline("@" + identity.name)

    text = ""
    tweets.each{| tweet |
        text = text + " " + tweet[:text]
    }

    topics = ""
    analytics_client = AylienTextApi::Client.new
    concepts = analytics_client.concepts(text)[:concepts].keys
    concepts.each{ |concept| 
        topics = topics + "," + concept.to_s.split("/resource/")[1] 
    }
    topics[0] = ''

    event = Hash.new
    event['wripl_object_id'] = 0
    event['user_id'] = current_user.id
    event['event_type'] = "INSERT"
    event['keywords'] = ""
    event['topics'] = topics
    event['categories'] = ""

    response = HTTParty.post("http://staging.wripl.com/events.json", :body => { :event => event }.to_json, :headers => { 'Content-Type' => 'application/json' } )
    
  end
end