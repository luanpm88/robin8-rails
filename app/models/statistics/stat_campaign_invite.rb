class Statistics::StatCampaignInvite < ActiveRecord::Base

  self.table_name = "stat_campaign_invite";

  def self.find_campaign_invite(tag_name, report_date)

    adminTag = Admintag.find_by(tag: tag_name)
    Statistics::StatCampaignInvite.find_by_sql("select
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
and ci.created_at >=
-- '2017-09-11'
DATE_ADD(DATE_FORMAT('" + report_date + "', '%Y-%m-%d'), INTERVAL -7 DAY)
-- DATE_ADD('" + report_date + "'), INTERVAL -7 DAY),

and ci.created_at <
-- '2017-09-18'
DATE_FORMAT('" + report_date + "', '%Y-%m-%d')

group by admintags.tag, data_date
order by data_date asc "
    )

  end

  # def self.load_data
  #   #Statistics::StatCampaignInvite.find_by_sql("insert into stat_campaign_invite ('tag)
  #
  # end

end
