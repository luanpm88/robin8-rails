class KolCategory < ActiveRecord::Base
  belongs_to :kol
  belongs_to :identity
  belongs_to :iptc_category
end
