class Circle < ActiveRecord::Base
  has_many :tags_circles, class_name: "TagsCircle"
  has_many :tags, through: :tags_circles
end
