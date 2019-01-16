# encoding: utf-8
namespace :creations do

	task :gen_trademarks => :environment do
		Trademark.create(
			user_id: 829,
			name: 'YSL',
			description: 'YSL（Yves Saint laurent）的简称，中文译名圣罗兰，是法国著名奢侈品牌，由1936年8月1日出生于法属北非阿尔及利亚的伊夫圣罗兰先生创立，主要有时装、护肤品，香水，箱包，眼镜，配饰等。'
			)
	end

	task :gen => :environment do
		u = User.find 829
		attrs = {
			user_id: u.id,
			name: '寻找大V',
			description: '推荐YSL黑鸦片',
			img_url: 'https://cdn.robin8.net/ysl.jpeg',
			trademark_id: u.trademarks.first.id,
			start_at: Time.now,
			end_at: 20.days.since,
			pre_kols_count: 20,
			pre_amount: 10000000,
			notice: '你牛，你上'
		}

		Creation.create(attrs)
	end

end