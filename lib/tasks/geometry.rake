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

	# RAILS_ENV=production bundle exec rake geometry:export_kols['2018-06-1']
	task :export_kols, [:start] => [:environment] do |t, args|
		admintag = Admintag.find 429
		start    = Time.parse(args[:start])

		CSV.open("tmp/geometry.csv","wb") do |csv|
      csv << %w(昵称 手机号 注册时间 师傅手机号 已接活动数 有效点击数 总点击数 可提现金额 历史净收益)
      Kol.admintag(admintag.tag).recent(start, Time.now).each do |k|
      	p "input........#{k.id}"
        csv << [k.name, k.mobile_number, k.created_at, k.parent.try(:mobile_number), k.campaign_invites.count, k.campaign_shows.valid.count, k.campaign_shows.count, k.avail_amount, k.historical_income]
      end
    end
    p "done ........."
	end

end