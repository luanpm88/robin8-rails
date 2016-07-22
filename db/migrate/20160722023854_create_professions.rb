class CreateProfessions < ActiveRecord::Migration
  def change
    create_table :professions do |t|
      t.string :name, :limit => 50
      t.string :label
      t.integer :position
      t.boolean :enable, :default => true

      t.timestamps null: false
    end

    add_index :professions, :name, :unique => true

    {
      'realestate'        => '房地产',
      'finance'           => '财经',
      'digital'           => '数码',
      'internet'          => '互联网',
      'appliances'        => '家电',
      'games'             => '游戏',
      'education'         => '教育',
      'health'            => '健康',
      'mobile'            => '手机',
      'fashion'           => '时尚',
      'books'             => '图书',
      'ce'                => '消费电子',
      'sports'            => '体育',
      'airline'           => '航空',
      'entertainment'     => '娱乐',
      'furniture'         => '家居',
      'babies'            => '母婴',
      'travel'            => '旅游',
      'auto'              => '汽车',
      'hotel'             => '酒店',
      'camera'            => '摄影',
      'food'              => '美食',
      'beauty'            => '美妆',
      'fitness'           => '健身',
      'music'             => '音乐',
      'overall'           => '综合'
    }.each_with_index do |(key, value), index|
      Profession.create!(name: key, label: value, position: index + 1)
    end

  end
end
