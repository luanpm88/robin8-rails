class KolsCircle < ActiveRecord::Base
  self.table_name = "kols_circles"
  
  belongs_to :kol
  belongs_to :circle
end
