class Statistics::CampaignInvite < ActiveRecord::Base
  
  def self.find_campaign_invite(tag_name, rd)
    Statistics::CampaignInvite.find_by_sql("select
			admintags.tag,
			DATE_FORMAT(ci.created_at, '%Y-%m-%d') as data_date,
			count(ci.id) as total_activity_count
			from campaign_invites ci,
			campaigns c, kols,
			admintags, admintags_kols
			where c.id =ci.campaign_id
			and ci.kol_id = kols.id
			and kols.id = admintags_kols.kol_id
			and admintags_kols.admintag_id = admintags.id
			and admintags.tag = '" + tag_name + "'
			and ci.created_at BETWEEN '" + rd.ago(6.days).beginning_of_day.to_s + "' 
			AND '" + rd.end_of_day.to_s + "'

			group by admintags.tag, data_date
			order by data_date asc "
    )

  end
end
