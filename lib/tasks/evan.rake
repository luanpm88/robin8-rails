# encoding: utf-8
namespace :evan do

	task :gen_kols => :environment do
		if $redis.lpop("dope_sample_data").nil?
      Partners::Alizhongbao.import_dope_data("/home/deployer/ali_kol_nickname_and_avatar.csv")
    end
		600.times do
	    avatar_url = eval($redis.lpop("dope_sample_data"))[0]
	    nickname   = eval($redis.lpop("dope_sample_data"))[1].gsub("'","")
	    Kol.create(channel: 'robot', avatar_url: avatar_url, name: nickname, gender: 1, age: Array(18..30).sample)
	  end
	end

	task :gen_campaign_invites => :environment do
		c = Campaign.find 5395
		# Kol.where("channel=? and id>?", 'robot', 195000).count
		Kol.where(channel: 'robot').each do |k|
			uuid = Base64.encode64({campaign_id: c.id, kol_id: k.id}.to_json).gsub("\n","")
			short_url = ShortUrl.convert("#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}")
			ci = CampaignInvite.create(campaign_id: c.id, kol_id: k.id, img_status: 'pending', approved_at: Time.now, status: 'approved', uuid: uuid, share_url: short_url)
			k.generate_invite_task_record

			ci.redis_avail_click.set rand(7)
			ci.redis_total_click.set rand(20)+ci.redis_avail_click.value.to_i
			c.redis_total_click.incr(ci.redis_total_click.value)
			c.redis_avail_click.incr(ci.redis_avail_click.value)
		end
	end

	# RAILS_ENV=production bundle exec rake evan:ban_campaign_invites
	task :ban_campaign_invites => :environment do
		c = Campaign.find(5774)

		c.valid_invites.each do |ci|
			if ci.kol.name == '🙄'
				p "*" * 100
				ci.update_columns(status: 'rejected')
				tr = Transaction.where(account: ci.kol, item: c).first
				if tr
					tr.account.confiscate(tr.credits, 'confiscate', nil, nil)
					p tr.credits.to_f
					tr.account.update_attributes(forbid_campaign_time: 10.years.since)
				end
			end
		end
	end

	task :gen_circles => :environment do
		# Circle.delete_all
		%w(时尚圈 数码发烧友 理财圈 白领圈 电影爱好者 体育圈 读书爱好者 单身圈 二次元 
			车友圈 旅游圈 吃货圈 房产圈 游戏圈 宝妈圈 网红圈 健身圈 投资圈 精英俱乐部 网购达人 企业家 宠物圈 校园圈).each do |ele|
				Circle.create(label: ele)
		end
	end

end