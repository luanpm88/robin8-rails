class CampaignTarget < ActiveRecord::Base
  TargetTypes = {
    :remove_campaigns => "去掉参与指定活动的人(填写campaign_id)",
    :remove_kols      => "去掉指定的kols(填写kol_id)",
    :add_kols         => "添加指定的kols(填写(kol_id)",
    :specified_kols   => "仅特定的kols(填写(kol_id)",
    :social_accounts  => "特邀活动指定的社交账号(social_account_id)",
    :newbie_kols      => "对于新人的kols可见(填写(any)",
    :ios_platform      => "IOS平台(过滤content不需要填)",
    :android_platform  => "Android平台(过滤content不需要填)"
  }
  attr_accessor :target_type_text

  belongs_to :campaign
  before_validation :set_target_type_by_text

  validates_presence_of :target_type
  validates_presence_of :target_content, :if => Proc.new{|t| t.target_type != 'ios_platform' && t.target_type != 'android_platform' }
  validates_inclusion_of :target_type, :in => %w(age region gender influence_score tags sns_platforms remove_campaigns remove_kols add_kols specified_kols newbie_kols social_accounts ios_platform android_platform)



  def set_target_type_by_text
    if self.target_type.blank? and self.target_type_text.present?
      self.target_type = TargetTypes.select{|key, value| value ==  self.target_type_text}.keys.first
    end
  end

  def get_target_type_text
    TargetTypes[self.target_type.to_sym]
  end

  def get_citys
    return [] if target_type != 'region' ||  target_content.blank?
    city_name_ens = []
    target_content.split("/").each do |region|
      city = City.where("name like '#{region[0,2]}%'").first
      if city
        city_name_ens << city.name_en
      else
        province = Province.where("name like '#{region[0,2]}%'").first
        if province
          province.cities.each do |city|
            city_name_ens << city.name_en
          end
        end
      end
    end
    city_name_ens
  end

  def get_tags
    return [] if target_type != 'tags'
    self.class.find_tags(target_content)
  end

  def get_sns_platforms
    return [] if target_type != 'sns_platforms'
    self.class.find_sns_platforms(target_content)
  end

  def get_score_value
    return 0 if target_type != 'influence_score'
    self.target_content.split("_").last.to_i rescue 0
  end

  def filter(kols)
    target_filter = "filter_target_#{self.target_type}_kols"
    return kols unless self.class.respond_to? target_filter

    self.class.send(target_filter, kols, self.target_content)
  end

  class << self

    def find_tags(content)
      return [] if content.blank?

      tag_names = content.split(",").reject(&:blank?)
      Tag.where(name: tag_names).map(&:id)
    end

    def find_sns_platforms(content)
      return [] if content.blank?

      content.split(",").reject(&:blank?)
    end

    def filter_target_region_kols(kols, content)
      unless content == '全部' || content == '全部 全部'
        cities = content.split(/[,\/]/).collect { |name| City.where("name like '#{name}%'").first.name_en }
        kols = kols.where(:app_city => cities)
      end
      kols
    end

    def filter_target_tags_kols(kols, content)
      unless content == '全部'
        kols = kols.joins("INNER JOIN `kol_tags` ON `kols`.`id` = `kol_tags`.`kol_id`")
        kols = kols.where("`kol_tags`.`tag_id` IN (?)", CampaignTarget.find_tags(content))
      end
      kols
    end

    def filter_target_sns_platforms_kols(kols, content)
      unless content == '全部'
        kols = kols.joins("INNER JOIN `social_accounts` ON `kols`.`id` = `social_accounts`.`kol_id`")
        kols = kols.where("`social_accounts`.`provider` IN (?)", CampaignTarget.find_sns_platforms(content))
      end
      kols
    end

    def filter_target_age_kols(kols, content)
      unless content == '全部'
        min_age = content.split(/[,\/]/).map(&:to_i).first
        max_age = content.split(/[,\/]/).map(&:to_i).last
        kols = kols.where(age: Range.new(min_age, max_age))
      end
      kols
    end

    def filter_target_gender_kols(kols, content)
      unless content == '全部'
        kols = kols.where(gender: content.to_i)
      end
      kols
    end
  end
end
