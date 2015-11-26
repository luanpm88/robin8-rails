class AddColumnToIptcCategories < ActiveRecord::Migration
  def change
    add_column :iptc_categories, :scene, :string
    add_column :iptc_categories, :name, :string


    IptcCategory.all.each do  |c|
      c.name = c.label
      c.scene = 'US'
      c.save
    end

    zh_start_id = 50000000
    zh_categories = { 'auto':'汽车', 'digit': '数码', 'education': '教育', 'health': '健康', 'sport': '体育', 'makeup': '美妆',
      'furniture': '家具', 'travel': '旅游', 'dish': '美食', 'clothing': '服饰', 'finance': '财经', 'music': '音乐', 'military': '军事',
      'baby': '母婴', 'lottery': '彩票', 'phone': '手机',
      'computer': '计算机', 'digitcamera': '数码相机', 'game': '游戏', 'house': '房地产', 'ent': '娱乐', 'cartoon': '卡通',
      'pet': '宠物', 'jd': '家电', 'luxury': '奢侈品', 'career': '找工作', 'law': '法律', 'unknown': '其他' }
    zh_categories.each do |key, value|
      ip_cate = IptcCategory.new
      ip_cate.id = zh_start_id
      ip_cate.name = key
      ip_cate.label = value
      ip_cate.level = 1
      ip_cate.scene = 'CN'
      ip_cate.save
      zh_start_id += 1000000
    end
  end
end
