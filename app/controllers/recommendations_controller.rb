require 'httparty'
require 'json'
require 'twitter'

class RecommendationsController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    #only process the request once
    def analyse_tweets
        status = "OK"
        request_count = nil
        identity = Identity.where("user_id = #{current_user.id} AND provider = 'twitter'").first
        if params[:request_count] != nil
            request_count = params[:request_count]
        end

        if request_count == "0" && !identity.blank?

            twitter_client = Twitter::REST::Client.new do |config|
                config.consumer_key        = Rails.application.secrets.twitter[:api_key]
                config.consumer_secret     = Rails.application.secrets.twitter[:api_secret]
                config.access_token        = identity.token
                config.access_token_secret = identity.token_secret
            end

            tweets = twitter_client.user_timeline("@" + identity.name)

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

            response = HTTParty.post("http://#{Rails.application.secrets.recsys}/events.json",
                                     :body => { :event => event }.to_json,
                                     :headers => { 'Content-Type' => 'application/json' } )

        elsif request_count != "0"
            status = "Only Processes Request Once"
        else
            status = "No Twitter Identity"
        end

        render json: '{"Status" : "' + status + '"}'

    end

    def event
        if validate_event(params)
            event = Hash.new
            event['wripl_object_id'] = params['event']['wripl_object_id']
            event['user_id'] = params['event']['user_id']
            event['event_type'] = params['event']['event_type']
            event['keywords'] = params['event']['keywords']
            event['topics'] = params['event']['topics']
            event['categories'] = params['event']['categories']

            response = HTTParty.post("http://#{Rails.application.secrets.recsys}/events.json",
                    :body => { :event => event }.to_json,
                    :headers => { 'Content-Type' => 'application/json' } )

            render json: event, status: :created
        else
          render json: "{'Errors' : 'Invlaid Event Attributes'}".to_json, status: :bad_request
        end
    end

    def status
        if validate_params(params)
            response = HTTParty.get("http://#{Rails.application.secrets.recsys}/recommendations/status/" +
                                    params['id'] + ".json?last_sign_in_at=" + params['last_sign_in_at'],
                            :options => { :headers => { 'Content-Type' => 'application/json' }})
            render json: response.to_json
        else
          render json: "{'Errors' : 'Incorrect Parameters'}".to_json, status: :bad_request
        end
    end

	def index
        recommended_stories = Array.new
        type = "CONTENT"
        page = 0
        user_id = current_user

        if current_user
            user_id = current_user.id
        else
            user_id = 0
        end

        if params[:type] != nil
            type = params[:type].upcase
        end

        if params[:page].to_i != nil
         page = params[:page].to_i
        end

        begin
            response = HTTParty.get("http://#{Rails.application.secrets.recsys}/recommendations/#{user_id}.json",
                                    :options => { :headers => { 'Content-Type' => 'application/json' }})
            json_recommendation_ids = JSON.parse(response.body)
        rescue Net::ReadTimeout
            logger.info "Operation Timedout"
            json_recommendation_ids = Array.new
            render json: json_recommendation_ids
        end

        case response.code
          when 200
            logger.info "Request proceesed"
          when 404
            logger.info "Resource Not Found"
          when 500...600
            logger.info "Server Rrror"
        end

        #Pagination is conducted here
        if json_recommendation_ids.size != 0
            if type == "CONTENT"
                recommended_ids = eval(json_recommendation_ids['content_story_ids'])
            elsif type == "INFLUENCE"
                recommended_ids = eval(json_recommendation_ids['influence_story_ids'])
            else
                recommended_ids = eval(json_recommendation_ids['content_story_ids']) + eval(json_recommendation_ids['influence_story_ids'])
                recommended_ids = recommended_ids.shuffle
            end
            recommended_stories = stories(page, recommended_ids.each_slice(15).to_a)
        end

		render json:  recommended_stories
	end

    private

    def validate_event(params)
        valid_event = true
        eventTypes = ['VIEW', 'LIKE', 'DISLIKE', 'SHARE', 'INSERT', 'INFLUENCE']
        if !params.has_key? 'event'
            valid_event = false
        end
        if !params['event'].has_key? 'wripl_object_id'
            valid_event = false
        end
        if !params['event']['wripl_object_id'].is_a? Numeric
            valid_event = false
        end
        if !params['event'].has_key? 'user_id'
            valid_event = false
        end
        if !params['event']['user_id'].is_a? Numeric
            valid_event = false
        end
        if !params['event'].has_key? 'event_type'
            valid_event = false
        end
        if !eventTypes.include? params['event']['event_type']
            valid_event = false
        end
        valid_event
    end

    def validate_params(params)
        valid_params = true
        if !params.has_key? 'id'
            valid_event = false
        end
        if !params['id'].is_a? Numeric
            valid_event = false
        end
        if !params.has_key? 'last_sign_in_at'
            valid_event = false
        end
        valid_params
    end

    def stories(page, pages)
        recommended_stories = []
        base_url = Rails.application.secrets.robin_api_url + "uniq_stories"
        if page < pages.size
            params = "?"
            references = Hash.new
            emails = Hash.new
            pages[page].each{|current_page|
                id = current_page[:id].to_s
                references[id] = { "reference" => current_page[:reference],
                                   "recommendation_type" => current_page[:recommendation_type],
                                   "email" => current_page[:email] }
                params = params + "ids[]=#{id}&"
            }
            params = params = params + "per_page=100"
            url = base_url + params

            auth = {:username => Rails.application.secrets.robin_api_user,
                    :password => Rails.application.secrets.robin_api_pass}
            stories = JSON.parse(HTTParty.get(url, :basic_auth => auth).body)
            recommended_stories = []

            # Add in the reference - why this recommendation?
            stories["stories"].each{ |story|
                share_count = 0
                id = story['id'].to_s
                story['email'] = references[id]['email']
                story['reference'] = references[id]['reference']
                story['recommendationType'] = references[id]['recommendation_type']
                story['shares_count'].each{ |key, value|
                    share_count = share_count + value
                }
                story['shares_count'] = share_count
                recommended_stories.push(story)
            }
            recommended_stories
        end
        recommended_stories
    end



end
