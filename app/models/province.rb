# encoding: utf-8

class Province < ActiveRecord::Base

  has_many :cities, dependent: :destroy
  has_many :districts, through: :cities

  def short_name
    @short_name ||= name.gsub(/市|省|回族自治区|壮族自治区|维吾尔自治区|自治区|特别行政区/, '')
  end
end
