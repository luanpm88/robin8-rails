class VoterShip < ActiveRecord::Base
	include Redis::Objects

	counter :redis_count

	belongs_to :kol
	belongs_to :voter, class_name: Kol, foreign_key: :voter_id
end
