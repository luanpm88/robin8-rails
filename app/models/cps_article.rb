class CpsArticle < ActiveRecord::Base
  has_many :cps_article_materials
  belongs_to :author, :foreign_key => :kol_id, :class_name => 'User'
  has_many :cps_materials, :through => :cps_article_materials
  count :read_count

  before_save :build_article_materials
  mount_uploader :cover, ImageUploader

  def show_url
    "#{Rails.application.secrets[:host]}/mobile/cps_materials/#{self.id}"
  end

  def content_arr
    self.content.split(/(<text>)|(<img>)|(<product>)/)       rescue []
  end

  def parse_content
  end

  def build_article_materials
    if  self.content_changed?
      arr = self.content.split(/(<product>)/)
      index = 0
      product_ids = []
      while index < arr.length
        if arr[index] == "<product>"
          product_ids <<  arr[index + 1]
          index = index + 2
        else
          index = index + 1
        end
      end
      self.cps_material_ids = product_ids
    end
  end

end
