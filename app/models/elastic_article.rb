class ElasticArticle < ActiveRecord::Base

	def self.weibo_pics(pic_str)
		{
			thumbnail: 		"http://ww3.sinaimg.cn/thumbnail/#{pic_str}.jpg",
			bmiddle_pic: 	"http://ww3.sinaimg.cn/bmiddle/#{pic_str}.jpg",
			large: 				"http://ww3.sinaimg.cn/large/#{pic_str}.jpg" 
		}
	end

	def self.weibo_pic_ary(pic_str)
		bmiddle_ary, large_ary = [], []
		pic_str.split(',').each do |str|
			bmiddle_ary << "http://ww3.sinaimg.cn/bmiddle/#{str}.jpg"
			large_ary 		<< "http://ww3.sinaimg.cn/large/#{str}.jpg" 
		end

		[bmiddle_ary, large_ary]
	end

end
