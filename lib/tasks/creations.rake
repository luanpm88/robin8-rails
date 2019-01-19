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

		c = Creation.create(attrs)

		# select plateform
		t = Terrace.find_by_name '公众号'
		CreationsTerrace.create(creation_id: c.id, terrace_id: t.id, exposure_value: 200000000)

		c.targets_hash[:category] = 'beauty'
		c.targets_hash[:price_from] = 2000
		c.targets_hash[:price_to] = 100000
		# select kol(BigV)
		kol_ary = [
			['iiiher', '她刊', 'http://wx.qlogo.cn/mmhead/Q3auHgzwzM5EWnemquKXZm1P9NXfWbhYDmiaYWAqLH8muUuB1ABNQXw/132', '青岛视觉志文化传媒有限公司'],
			['GQZHIZU', 'GQ实验室', 'http://wx.qlogo.cn/mmhead/Q3auHgzwzM5CnVukVdDnTIMWNEPIdRhjaLxdKnCfPBPXLV0fpm87Zw/132', '北京风华创想网络有限公司'],
			['weikagirl', '卡妞范儿', 'http://wx.qlogo.cn/mmhead/Q3auHgzwzM7ot5ItQtkQMM1nrb5nnQ7iaNdlQAV4w8aibKsPcibVg203g/132', '深圳量子云科技有限公司']
		]

		kol_ary.each do |ele|
			CreationSelectedKol.create(
				from_by: 'select',
				creation_id: c.id,
				plateform_name: 'public_wechat_account',
				plateform_uuid: ele[0],
				name: ele[1],
				avatar_url: ele[2],
				desc: ele[3]
			)
		end

		c.reload

		# kol_116045绑定一个creation_selected_kol
		k = c.creation_selected_kols.sample
		k.kol_id = 116045
		k.save
	end

	task :pass => :environment do
		c = Creation.first
		# valid pass
		c.update_attributes(status: 'passed', fee_rate: '0.2')
	end

	task :tender => :environment do
		c = Creation.first
		_select_kol = c.creation_selected_kols.find_by_kol_id 116045

		Tender.create(
			creation_id: c.id,
			kol_id: _select_kol.kol_id,
			creation_selected_kol_id: _select_kol.id,
			from_terrace: 'wechat_public_account',
			price: 30000,
			fee: 30000 * c.fee_rate
		)
	end

end