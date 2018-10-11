class Circle < ActiveRecord::Base
  #tags
  has_many :tags_circles, class_name: "TagsCircle"
  has_many :tags, through: :tags_circles

  #kols
  has_many :kols_circles, class_name: "KolsCircle"
  has_many :kols, through: :kols_circles

end
