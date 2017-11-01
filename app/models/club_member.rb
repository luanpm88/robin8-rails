class ClubMember < ActiveRecord::Base
  belongs_to :club
  belongs_to :kol
  # has_one :kol
end
