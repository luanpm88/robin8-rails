class VoterShip < ActiveRecord::Base

	belongs_to :kol
	belongs_to :voter, class_name: Kol, foreign_key: :voter_id
end
