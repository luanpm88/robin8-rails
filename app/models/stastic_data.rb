class StasticData < ActiveRecord::Base
  after_create :async_stastic_data

  def async_stastic_data
    StasticDataHandler.perform_async self.id
  end

  def self.from_source
    sql = "select DATE(created_at) as created,utm_source, count(*) as count
          from
            (select * from kols
              where id > 45000
              group by device_token
            ) as uniq_ds
          where utm_source is not null
          group by DATE(created_at),utm_source
          order by created desc
          limit 64"
    result = Kol.find_by_sql(sql)
    result.group_by{|t| t.created}
  end

  def self.day_statistics_value(_start)
    sql = "select DATE(created_at) as created, count(*) as count
          from
            (select * from kol_influence_values
              group by kol_id
            ) as uniq_values
          where created_at > '#{_start}'
          group by DATE(created_at)
          order by created asc"
    result = KolInfluenceValue.find_by_sql(sql)
  end

  def self.day_statistics_article(_start)
    sql = "select DATE(created_at) as created, count(*) as count
          from
            (select * from article_actions
              group by kol_id
            ) as uniq_article_actions
          where created_at > '#{_start}' and forward = 1
          group by DATE(created_at)
          order by created asc"
    result = ArticleAction.find_by_sql(sql)
  end

  def self.day_statistics_invite(_start)
    sql = "select DATE(created_at) as created, count(*) as count
          from
            (select * from campaign_invites
              group by kol_id
            ) as uniq_campaign_invites
          where created_at > '#{_start}'
          group by DATE(created_at)
          order by created asc"
    result = CampaignInvite.find_by_sql(sql)
  end
end
