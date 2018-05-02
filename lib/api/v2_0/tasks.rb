# encoding: utf-8
module API
  module V2_0
    class Tasks < Grape::API
    	resources :tasks do
        before do
          authenticate!
        end

        get '/' do
        	present :error, 0
        	present :total_check_in_amount, 	current_kol.total_check_in_amount
          present :today_can_amount, 				current_kol.today_can_amount
          present :today_had_check_in,      current_kol.today_had_check_in?
        	present :check_in_7, 							current_kol.check_in_7
        	present :campaign_invites_count, 	current_kol.campaign_invites.today.count
        	present :invite_friends, 					current_kol.today_invite_count
      	end

      end
    end
  end
end