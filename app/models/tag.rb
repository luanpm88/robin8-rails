class Tag < ActiveRecord::Base

  default_scope ->{where(:enabled => true)}
  NameLabel = Tag.all.inject({}){|h, t| h[t.name] = t.label; h}

  # def self.add_test_tags
  #   index = 0
  #   categories = { 'auto':'汽车', 'digit': '数码', 'education': '教育', 'health': '健康', 'sport': '体育', 'makeup': '美妆',
  #     'furniture': '家具', 'travel': '旅游', 'dish': '美食', 'clothing': '服饰', 'finance': '财经', 'music': '音乐', 'military': '军事',
  #     'baby': '母婴', 'lottery': '彩票', 'phone': '手机',
  #     'computer': '计算机', 'digitcamera': '数码相机', 'game': '游戏', 'house': '房地产', 'ent': '娱乐', 'cartoon': '卡通',
  #     'pet': '宠物', 'jd': '家电', 'luxury': '奢侈品', 'career': '找工作', 'law': '法律', 'unknown': '其他' }
  #   categories.each do |key,value|
  #     Tag.create(:name => key, :label => value, :position => index + 1)
  #     index += 1
  #   end
  # end

  has_many :elastic_articles

  def self.get_lable_by_name(name)
    return "全部" if(name == "全部")
    Tag.where(name: name).take.label    rescue nil
  end

  def self.get_name_by_label(label)
    return "全部" if(label == "全部")
    Tag.where(label: label).take.name rescue nil
  end

end
