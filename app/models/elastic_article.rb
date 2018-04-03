class ElasticArticle < ActiveRecord::Base

	def self.weibo_pics(pic_str)
		{
			thumbnail: 		"http://ww3.sinaimg.cn/thumbnail/#{pic_str}.jpg",
			bmiddle_pic: 	"http://ww3.sinaimg.cn/bmiddle_pic/#{pic_str}.jpg",
			large: 				"http://ww3.sinaimg.cn/large/#{pic_str}.jpg" 
		}
	end 

end
