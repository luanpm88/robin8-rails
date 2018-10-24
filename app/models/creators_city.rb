class CreatorsCity < ActiveRecord::Base
  self.table_name = "creators_cities"
  
  belongs_to :creator
  belongs_to :city
end
