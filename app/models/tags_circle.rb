class TagsCircle < ActiveRecord::Base
  self.table_name = "tags_circles"
  
  belongs_to :tag 
  belongs_to :circle
end
