class AddMoreTags < ActiveRecord::Migration
  def change
    Tag.unscoped.find_by(:name => 'airline').update_column(:enabled, true)
    Tag.find_by(:name => 'ce').update_column(:label, '消费电子')
    Tag.unscoped.find_by(:name => 'camera').update_columns(:label => '摄影', :enabled => true)
    Tag.find_by(:name => 'internet_consumption').update_columns(:enabled => false)
    Tag.unscoped.find_by(:name => 'mobile').update_columns(:enabled => true)

    {
      'realestate'        => '房地产',
      'digital'           => '数码',
      'appliances'        => '家电',
      'books'             => '图书',
      'sports'            => '体育',
      'entertainment'     => '娱乐',
      'furniture'         => '家居',
      'music'             => '音乐',
      'overall'           => "综合"
    }.each_with_index do |(key, value), index|
      Tag.create!(name: key, label: value, :enabled => true)
    end
  end
end

# {
#   'realestate'        => '房地产',
#   'finance'           => '财经',
#   'digital'           => '数码',
#   'internet'          => '互联网',
#   'appliances'        => '家电',
#   'games'             => '游戏',
#   'education'         => '教育',
#   'health'            => '健康',
#   'mobile'            => '手机',
#   'fashion'           => '时尚',
#   'books'             => '图书',
#   'ce'                => '消费电子',
#   'sports'            => '体育',
#   'airline'           => '航空',
#   'entertainment'     => '娱乐',
#   'furniture'         => '家居',
#   'babies'            => '母婴',
#   'travel'            => '旅游',
#   'auto'              => '汽车',
#   'hotel'             => '酒店',
#   'camera'            => '摄影',
#   'food'              => '美食',
#   'beauty'            => '美妆',
#   'fitness'           => '健身',
#   'music'             => '音乐',
#   'overall'           => "综合"
# }
