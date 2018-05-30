class Statistics::BrandSettledTakeBudget < ActiveRecord::Base

  belongs_to :user
  
  def self.calculate_brand_settled_take_budget 
    adminTag = Admintag.find_by_tag "geometry"
    page_size = 100
    index = 0
    
    ActiveRecord::Base.transaction do
      self.delete_all

      while index < self.brand_count
        self.brand_settled_take_budgets(page_size, index).each do |c|
          self.create(
            tag: c.tag,
            user_id: c.user_id,
            total_campaign_count: c.total_campaign_count,
            total_take_budget: c.total_take_budget,
            deleted: 0,
            created_by: 'system',
            updated_by: 'system'
          )
        end
        index += page_size
      end
    end
  end

  def self.brand_count
    self.find_by_sql("select user_id, tag, count(id) as total_campaign_count,
                      sum(take_budget) as total_take_budget from
                      statistics_campaign_settled_take_budgets group by user_id, tag").count
  end

  def self.brand_settled_take_budgets(page_size, index)
    self.find_by_sql("select user_id, tag, count(id) as total_campaign_count, 
                      sum(take_budget) as total_take_budget from statistics_campaign_settled_take_budgets 
                      group by user_id, tag limit " + page_size.to_s + " offset " + index.to_s
                    )
  end

end
