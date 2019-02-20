class CreationsTerrace < ActiveRecord::Base
  self.table_name = "creations_terraces"
  
  belongs_to :creation
  belongs_to :terrace
end
