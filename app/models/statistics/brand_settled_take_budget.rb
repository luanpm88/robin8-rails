class Statistics::BrandSettledTakeBudget < ActiveRecord::Base
  
  def self.calculate_brand_settled_take_budget 
    
    adminTag = Admintag.find_by_tag "geometry"
    page_size = 100
    index = 0
    beginTime = Time.new

    result = Array.new
    
    ActiveRecord::Base.transaction do
      
      self.delete_all

      loop do
        brand_count = self.find_by_sql("select user_id, tag, count(id) as total_campaign_count,
  sum(take_budget) as total_take_budget from statistics_campaign_settled_take_budgets group by user_id, tag").count

        if index > brand_count
          # no record anymore
          break
        else

          brandSettledTakeBudgets = self.find_by_sql("select user_id, tag, count(id) as total_campaign_count,
              sum(take_budget) as total_take_budget from statistics_campaign_settled_take_budgets group by user_id, tag limit " + page_size.to_s + " offset " + index.to_s
            )

          brandSettledTakeBudgets.each do |c|

            bTakeBudget = self.new
            bTakeBudget.tag = c.tag
            bTakeBudget.user_id = c.user_id

            bTakeBudget.total_campaign_count = c.total_campaign_count
            bTakeBudget.total_take_budget = c.total_take_budget
            bTakeBudget.deleted = 0
            bTakeBudget.created_at = Time.now
            bTakeBudget.updated_at = Time.now
            bTakeBudget.created_by = "system"
            bTakeBudget.updated_by = "system"
            bTakeBudget.save
          end

        end
        index = index + page_size
      end
    end
  end
end
