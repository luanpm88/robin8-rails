class CreatorsTerrace < ActiveRecord::Base
  self.table_name = "creators_terraces"
  
  belongs_to :creator
  belongs_to :terrace
end
