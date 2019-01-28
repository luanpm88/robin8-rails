# encoding: utf-8
namespace :votes do

	task :gen => :environment do
		VoterShip.create(kol_id: 1, voter_id: 2, count: 1)
		VoterShip.create(kol_id: 1, voter_id: 3, count: 1)
		VoterShip.create(kol_id: 2, voter_id: 3, count: 1)
		VoterShip.create(kol_id: 2, voter_id: 4, count: 1)

		Vote.create(kol_id: 1, tender_id: 2, date_show: '2018-11-15')
		Vote.create(kol_id: 1, tender_id: 3, date_show: '2018-11-15')
		Vote.create(kol_id: 2, tender_id: 3, date_show: '2018-11-15')
		Vote.create(kol_id: 2, tender_id: 4, date_show: '2018-11-15')
	end

	task :update_kol => :environment do
		_time = $redis.get('vote_last_update_time') || Time.now.ago(1.days)

		Kol.joins(:voter_ships).where('kols.id=voter_ships.kol_id and voter_ships.updated_at > ?', _time).uniq.each do |k|
			k.update_columns(is_hot: k.redis_votes_count.value)
		end

		$redis.set('vote_last_update_time', Time.now)

	end

	task :inits => :environment do
		Vote.delete_all
		VoterShip.delete_all
		Kol.where('is_hot is not null').each do |kol|
			kol.update_columns(is_hot: nil)
			kol.redis_votes_count.set nil
		end

		p Kol.count('is_hot > 0')
	end

end