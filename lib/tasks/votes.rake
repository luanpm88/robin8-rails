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

end