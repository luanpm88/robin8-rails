class CreatorsCircle < ActiveRecord::Base
  self.table_name = "creators_circles"
  
  belongs_to :creator
  belongs_to :circle
end
