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
  		Transaction.where(direct: 'income', account_type: 'Kol', item: item, opposite: item.user).group_by{|ele| ele.account_id}.each do |k, v|
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
      # 徒弟收益
      Transaction.where(direct: 'income', item: item, subject: 'percentage_on_friend').group_by{|ele| ele.opposite_id}.each do |k, v|
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

  desc '补上kol遗失收益'
  task :campaign_invite_settle_again do
    amount = 0.0
    Campaign.where("id>? and per_budget_type=? and status=?", 5202, 'click', 'settled').each do |c|
      c.campaign_invites.each do |ci|
        next if ci.status == 'settled'
        campaign_shows = CampaignShow.where(campaign_id: c.id, kol_id: ci.kol_id).valid
        if campaign_shows.count > 0
          if campaign_shows.map(&:transaction_id).uniq == [nil]
            credits = campaign_shows.size * c.get_per_action_budget(false)
            transaction = ci.kol.income(credits, 'campaign', c, c.user)
            campaign_shows.update_all(transaction_id: transaction.id)
            amount += credits
            ci.update_column(:status, 'settled')
            Rails.logger.info "*" * 10
            Rails.logger.info credits
          end
        end
      end
    end
  end

  task :robots do
    Campaign.where(id: [5013, 5012, 5008, 5007]).each do |c|
      c = Campaign.find 5008

      avail_click, kols_count = c.need_add_avail_click, c.need_add_kols_count

      click_ary = MathExtend.rand_array(avail_click, kols_count)

      Kol.where(channel: 'robot').sample(kols_count).each_with_index do |k, index|
        ci = CampaignInvite.find_or_initialize_by(campaign_id: c.id, kol_id: k.id)

        if ci.new_record?
          uuid      = Base64.encode64({campaign_id: c.id, kol_id: k.id}.to_json).gsub("\n","")
          short_url = ShortUrl.convert("#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}")
        
          ci.img_status   = 'passed'
          ci.approved_at  = Time.now 
          ci.status       = 'settled' 
          ci.uuid         = uuid
          ci.share_url    = short_url
          ci.save
          k.generate_invite_task_record
        end

        ci.redis_avail_click.incr click_ary[index]
        ci.redis_total_click.incr click_ary[index] + rand(20)
        ci.update_attributes(avail_click: ci.redis_avail_click.value, total_click: ci.redis_total_click.value)

        c.redis_avail_click.incr ci.avail_click
        c.redis_total_click.incr ci.total_click
      end
      c.update_attributes(avail_click: c.redis_avail_click.value, total_click: c.redis_total_click.value)
    end
  end
  
end
