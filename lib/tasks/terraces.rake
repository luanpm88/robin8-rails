# encoding: utf-8
namespace :terraces do

	task :gen => :environment do
		ary = {
			wechat: '微信',
			qq: 'QQ',
			weibo: '微博',
			public_wechat_account: '公众号',
			meipai: '美拍',
			miaopai: '秒拍',
			zhihu: '知乎',
			douyu: '斗鱼',
			inke: '映客',
			tieba: '贴吧',
			tianya: '天涯',
			taobao: '淘宝',
			huajiao: '花椒',
			nice:    'nice',
			douban: '豆瓣',
			xiaohongshu: '小红书',
			yizhibo: '一直播',
			meilapp: '美啦'
		}

		ary.each do |k, v|
			Terrace.create(name: v, short_name: k, address: "http://img.robin8.net/#{k}.png")
		end
	end

end