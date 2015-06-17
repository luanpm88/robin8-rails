require 'httparty'
require 'json'

class RecommendationsController < ApplicationController

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
            response = HTTParty.get("http://staging.wripl.com/recommendations/#{user_id}.json", :options => { :headers => { 'Content-Type' => 'application/json' }}, :timeout => 2)
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

        
        if json_recommendation_ids.size != 0
            if type == "CONTENT"
                
                recommended_ids = eval(json_recommendation_ids['content_story_ids'])
            elsif type == "INFLUENCE"
                recommended_ids = eval(json_recommendation_ids['influence_story_ids'])
            else
                recommended_ids = eval(json_recommendation_ids['content_story_ids']) + eval(json_recommendation_ids['influence_story_ids'])
            end
            recommended_stories = stories(page, recommended_ids.each_slice(25).to_a)
        end
        
		render json:  recommended_stories
	end

    private

    def stories(page, pages)
        recommended_stories = []
        base_url = "http://api.robin8.com/api/v1/stories"
        if page < pages.size
            params = "?"
            references = Hash.new
            pages[page].each{|current_page|
                references[current_page[:id].to_s] = current_page[:reference]
                params = params + "ids[]=#{current_page[:id]}&"
            }
            params = params = params + "per_page=25"
            url = base_url + params

            auth = {:username => "hamed@aylien.com", :password => "1234"}
            stories = JSON.parse(HTTParty.get(url, :basic_auth => auth).body)
            recommended_stories = []
           
            # Add in the reference - why this recommendation?
            stories["stories"].each{ |story|
                share_count = 0
                story['reference'] = references[story['id'].to_s]
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
