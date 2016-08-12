class KolShow < ActiveRecord::Base
  belongs_to :kol
  default_scope ->{order("id desc")}

end
