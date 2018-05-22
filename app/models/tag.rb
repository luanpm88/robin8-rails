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

  has_many :kol_tags
  has_many :elastic_articles

  def self.get_lable_by_name(name)
    return "全部" if(name == "全部")
    Tag.where(name: name).take.label    rescue nil
  end

  def self.get_name_by_label(label)
    return "全部" if(label == "全部")
    Tag.where(label: label).take.name rescue nil
  end

  # statistics
  def self.group_by_tag(limit, tag)
    # Tag.find_by_sql("select tags.name, count(kols.id) counter from kols, kol_tags, tags where kols.id = kol_tags.kol_id and tags.id = kol_tags.tag_id and tags.enabled = 1 GROUP BY tags.name order by count(kols.id) desc limit " + limit.to_s)
    Tag.find_by_sql("select c.* from (

select a.* , b.*, (a.tag_count / b.total_count ) * 100 as percentage from (

select tags.name, count(kols.id) as tag_count
from kols, kol_tags, tags, admintags_kols , admintags
where kols.id = kol_tags.kol_id
and tags.id = kol_tags.tag_id
and tags.enabled = 1
and admintags.tag = '" + tag + "'
and admintags_kols.admintag_id = admintags.id
and kols.id = admintags_kols.kol_id
group by tags.name
order by count(kols.id) desc
 limit 5
) a
left join (

select count(*) as total_count
from kols, kol_tags, tags, admintags_kols , admintags
where kols.id = kol_tags.kol_id
and tags.id = kol_tags.tag_id
and tags.enabled = 1
and admintags.tag = '" + tag + "'
and admintags_kols.admintag_id = admintags.id
and kols.id = admintags_kols.kol_id
) b on 1 = 1

) c order by percentage desc limit " + limit.to_s
    )
  end

  # statistics by app_city
  def self.group_by_app_city(limit, tag)
    Tag.find_by_sql("select c.* from (
select a.* , b.*, (a.city_count / b.total_count ) * 100 as percentage from (
select kols.app_city, count(*) as city_count
from kols, admintags_kols , admintags where admintags.tag = '" + tag + "'
and admintags_kols.admintag_id = admintags.id and kols.id = admintags_kols.kol_id
group by app_city
having app_city is not null
) a
inner join (
select count(*) as total_count
from kols, admintags_kols , admintags where admintags.tag = '" + tag + "'
and admintags_kols.admintag_id = admintags.id and kols.id = admintags_kols.kol_id
) b
) c order by percentage desc limit " + limit.to_s
)
  end
end
