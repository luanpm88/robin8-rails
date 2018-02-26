namespace :campaign  do
  desc "Manually execute campaign tasks"

  # Example usage:
  # command:
  # cap production invoke['campaign:process','4321 end']
  # will finialize campaign with ID 4321

  task :process, [:campaign_id, :job_type] => [:environment] do |t, args|
    CampaignWorker.perform_async(args[:campaign_id], args[:job_type])
  end


  desc '干掉重复收益，以及修改个人总金额'
  # RAILS_ENV=development rake campaign:check_income['2017-10-1','confiscate']
  task :check_income, [:time, :is_confiscate] => [:environment] do |t, args|
  	time, sum = Time.parse(args[:time]).beginning_of_day, 0
  	p time
  	Campaign.where("created_at > ?", time).each do |item|
  		Transaction.where(direct: 'income', account_type: 'Kol', item: item).group_by{|ele| ele.account_id}.each do |k, v|
  			if v.count > 1
  				sum += v.first.credits
  				if args[:is_confiscate] == 'confiscate'
  					tr = v.first
  					p "confiscate account_#{tr.account_id} item_#{tr.item_id} tr_#{tr.id}"
  					tr.account.confiscate(tr.credits, 'confiscate', nil, nil)
  					tr.destroy
  				end
  			end
  		end
  	end
  	p sum.to_f
  end
end
