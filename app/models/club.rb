class Club < ActiveRecord::Base
 belongs_to :kol
 has_many :club_numbers
end
