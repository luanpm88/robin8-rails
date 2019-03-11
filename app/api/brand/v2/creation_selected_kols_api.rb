module Brand
  module V2
    class CreationSelectedKolsAPI < Base
      group do
        resources :creation_selected_kols do

	        params do
	        	requires :id, type: String
	        end
	        get ":id/big_v_details" do
	        	selected_kols = CreationSelectedKol.where(plateform_uuid: params[:id])#.by_status(:finished)
	        	kol 					= selected_kols.first.try(:kol)

	        	total_info, last_30_days_info = [0, 0, 0], ["0/0%", "0/0%", 0]

	        	if kol
		        	total_cis   = kol.campaign_invites.passed
		        	last_cis    = kol.campaign_invites.passed.last_days(30)

		        	last_per, total_avg, last_avg, last_avg_per = 0, 0, 0, 0

		        	if total_cis.count > 0
		        		last_per    = last_cis.count*100/total_cis.count
		        		total_avg   = total_cis.sum(:total_click)/total_cis.count
		        		last_avg    = last_cis.sum(:total_click)/last_cis.count
		        	end

		        	last_avg_per 			= total_avg == 0 ? 0 : last_avg*100/total_avg
		        	total_info 				= [total_cis.count, total_avg, selected_kols.count]
		        	last_30_days_info = ["#{last_cis.count}/#{last_per}%", "#{last_avg}/#{last_avg_per}%", selected_kols.last_days(30).count]
		        end

		        present :data,              kol, with: Entities::BigVBaseInfoVue
	        	present :creations_list,    selected_kols, with: Entities::BigVCreationVue
	        	present :total_info,        total_info
	        	present :last_30_days_info, last_30_days_info
	        end

	      end
      end
    end
  end
end