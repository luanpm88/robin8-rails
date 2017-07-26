class UnbindTimestamp < ActiveRecord::Base
	
	def unbind_record(kol_id , provider , unbind_api)
	  unbind_timestamp = UnbindTimestamp.find_by(:kol_id => kol_id , :provider => provider , :unbind_api => unbind_api)
	  if unbind_timestamp
		UnbindTimestamp.update(:unbind_at => Time.now)
	  else
		UnbindTimestamp.create(:kol_id => kol_id , :provider => provider , :unbind => Time.now , :unbind_api => unbind_api)
	  end
   end
end
