# encoding: utf-8
namespace :geometry do

	task :update_kol => :environment do
		admintag = Admintag.find 429
		phones   = %w(18502105963 18926211010 13590312192 15902077627 15989118588)

		Kol.where(mobile_number: phones).each do |k|
			k.update_columns(admin_id: 105002)
			k.admintags << admintag
			invitation = RegisteredInvitation.pending.where(mobile_number: k.mobile_number).take
			invitation.update!(status: 'completed', invitee_id: k.id, registered_at: k.created_at) if invitation
		end
	end

end