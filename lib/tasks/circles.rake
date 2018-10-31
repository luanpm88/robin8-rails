# encoding: utf-8
namespace :circles do

	task :gen => :environment do
		arys = [
			'二次元——互联网 游戏 时尚 娱乐 家居 音乐 综合 电影 科技 美食',
			'车友圈——时尚 房地产 数码 家电 家居 音乐 电影 旅游 酒店 教育 健身 汽车',
			'旅游圈——时尚 健康 房地产 娱乐 音乐 综合 电影 美食 旅游 酒店 航空',
      '吃货圈——美食 电影 旅游',
      '房产圈——企业家 家居 房地产',
			'游戏圈——游戏 互联网 数码',
			'宝妈圈——美食 母婴 美妆 时尚 健康 旅游 教育', 
			'网红圈——综合',
			'女神圈——美妆 时尚 健康 旅游 美食 娱乐 音乐 酒店',
			'企业家——综合',
			'宠物圈——萌宠 美食 家居 电影',
			'校园圈——综合',
			'时尚圈——时尚 美妆 消费电子 网红 网购达人 娱乐 互联网',
      '数码发烧友——消费电子 网购达人 摄影 手机 科技 家电 游戏',
      '理财圈——财经 汽车 旅游 酒店 企业家',
      '白领圈——美食 酒店 旅游 互联网 娱乐 电影 音乐 图书 数码 健康',
      '健身圈——健身 旅游 美食 摄影 手机',
			'投资圈——综合',
			'精英俱乐部——综合',
			'网购达人——网购达人 美食 美妆 时尚 旅游 酒店',
      '电影爱好者——电影',
      '体育圈——体育 时尚 健康',
      '读书爱好者——图书 教育 财经',
      '单身圈——网红 互联网 时尚 娱乐 科技 旅游  美食 健身',
 		]
 		arys.each do |ele|
 			a, b = ele.split('——')
 			c = Circle.create(label: a)
 			c.tags << Tag.where(label: b.split(' '))
 		end
	end

	task :add_colors => :environment do
		colors = {
    	'#FFBFAD' => %w(二次元 游戏圈),
    	'#99B8FF' => %w(车友圈 宝妈圈 理财圈),
    	'#FFB8C6' => %w(旅游圈 时尚圈),
    	'#90D6FF' => %w(吃货圈 校园圈 精英俱乐部),
    	'#D7B9FF' => %w(房产圈),
    	'#FFBAAB' => %w(旅游圈 单身圈),
    	'#B6B6FF' => %w(网红圈),
    	'#85E2C9' => %w(女神圈 数码发烧友 电影爱好者),
    	'#8BCAFF' => %w(企业家 健身圈),
    	'#FFC399' => %w(宠物圈 体育圈),
    	'#8CD7F2' => %w(白领圈 读书爱好者),
    	'#8AC4FF' => %w(投资圈),
    	'#FCBAFF' => %w(网购达人)
    }
    colors.each do |k, v|
    	Circle.where(label: v).update_all(color: k)
    end
	end

	task :sort => :environment do
		ary = %w(二次元 车友圈 旅游圈 吃货圈 房产圈 游戏圈 宝妈圈 网红圈 女神圈 企业家 宠物圈 校园圈 时尚圈 数码发烧友 理财圈 白领圈 健身圈 投资圈 精英俱乐部 网购达人 电影爱好者 体育圈 读书爱好者 单身圈)
		ary.each do |ele|
			Circle.find_by_label(ele).update_columns(position: ary.index(ele))
		end
	end


end