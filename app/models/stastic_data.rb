class StasticData < ActiveRecord::Base
  after_create :async_stastic_data

  def async_stastic_data
    StasticDataHandler.perform_async self.id
  end

  def self.from_source
    sql = "select DATE(created_at) as created,utm_source, count(*) as count
          from
            (select * from kols
              group by device_token
            ) as uniq_ds
          where utm_source is not null
          group by DATE(created_at),utm_source
          order by created desc
          limit 64"
    result = Kol.find_by_sql(sql)
    result.group_by{|t| t.created}
  end
end
