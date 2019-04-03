#自媒体平台
class Terrace < ActiveRecord::Base

	NAME_EN = {
    weibo:                  'Weibo',
    public_wechat_account:  'Wechat',
    xiaohongshu:            'Xiaohongshu',
    kuaishou:               'Kuaishou',
    bilibili:               'Bilibili',
    douyin:                 'Douyin',
    facebook:               'Facebook',
    instagram:              'Instagram',
    youtube:                'YouTube'
  }
  
  validates :name, :short_name, presence:   {message: '不能为空'}
  validates :name, :short_name, uniqueness: {message: '已被占用'}

	#creator
  has_many :creators_terraces, class_name: "CreatorsTerrace"
  has_many :creators, through: :creators_terraces


  # creations
  has_many :creations_terraces, class_name: "CreationsTerrace"
  has_many :creations, through: :creations_terraces

  scope :now_use, -> {where(short_name: %w(weibo public_wechat_account xiaohongshu bilibili kuaishou douyin facebook youtube instagram))}

  def name_en
  	NAME_EN[short_name.to_sym]
  end

end
