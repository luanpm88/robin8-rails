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
  task :check_income => :environment do
  	sum = 0
  	Campaign.where("created_at > ?", Time.now.ago(21.days).beginning_of_day).each do |item|
  		Transaction.where(direct: 'income', account_type: 'Kol', item: item).group_by{|ele| ele.account_id}.each do |k, v|
  			if v.count > 1
  				sum += v.first.credits
  				tr = v.first
  				# tr.account.confiscate(tr.credits, 'confiscate', item, nil)
  			end
  		end
  	end
  end
end
