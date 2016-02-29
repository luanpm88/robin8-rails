class InitTagsAndUpgrade < ActiveRecord::Migration
  def change
    add_column :tags, :cover_url, :string
    tags = {
      food:	"美食",
      babies:	"母婴",
      travel:	"旅游",
      hotel:	"酒店",
      education:	"教育",
      fitness:	"健身",
      finance:	"财经",
      beauty:	"美妆",
      auto:	"汽车",
      airline:	"航空",
      ce:	"消费电子",
      camera:	"数码相机",
      mobile:	"手机"
    }
    start = 1
    tags.each do |key, value|
      tag = Tag.new
      tag.cover_url = "http://7xozqe.com2.z0.glb.qiniucdn.com/tag_#{key}.png"
      tag.name = key
      tag.label = value
      tag.position = start
      tag.save
      start += 1
    end

    AppUpgrade.create(:app_platform => "IOS", :app_version => '1.0.0', :release_at => Time.now, :release_note => "首次发布", :download_url => 'http://www.robin8.net')
    AppUpgrade.create(:app_platform => "Andriod", :app_version => '1.0.0', :release_at => Time.now, :release_note => "首次发布", :download_url => 'http://www.robin8.net')

  end
end
