class UpdateTags < ActiveRecord::Migration
  def change
    add_column :tags, :enabled, :boolean, :default => true
    Tag.find_by(:name => 'ce').update_column(:label, '数码电子')
    Tag.where(:name => ['camera', 'mobile', 'airline']).update_all(:enabled => false)
    Tag.create(:name => 'internet_consumption', :label => '电商消费')
    Tag.create(:name => 'internet', :label => '互联网')
    Tag.create(:name => 'game', :label => '游戏')
    Tag.create(:name => 'fashion', :label => '时尚')
    Tag.create(:name => 'health', :label => '健康')

    Tag.where(:enabled => true).each do  |tag|
      tag.update_column(:cover_url, "http://7xozqe.com2.z0.glb.qiniucdn.com/tag2_#{tag.name}.png")
    end
  end
end
