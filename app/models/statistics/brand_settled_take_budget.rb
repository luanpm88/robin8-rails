class Statistics::BrandSettledTakeBudget < ActiveRecord::Base
  def self.calculate_brand_settled_take_budget(tag_name)
    adminTag = Admintag.find_by(tag: tag_name)
    page_size = 100
    index = 0
    beginTime = Time.new

    result = Array.new
    loop do
      brand_count = Statistics::BrandSettledTakeBudget
                      .find_by_sql("select user_id, tag, count(id) as total_campaign_count,
sum(take_budget) as total_take_budget from statistics_campaign_settled_take_budgets group by user_id, tag").count

      puts "Looking records for Campaign page size : " + page_size.to_s + " index at: " + index.to_s

      puts "brand count " + brand_count.to_s
      puts ">>>>>>>>>>> c count " + brand_count.to_s

      if index > brand_count
        # no record anymore
        break
      else

        brandSettledTakeBudgets = Statistics::BrandSettledTakeBudget
          .find_by_sql("select user_id, tag, count(id) as total_campaign_count,
            sum(take_budget) as total_take_budget from statistics_campaign_settled_take_budgets group by user_id, tag limit " + page_size.to_s + " offset " + index.to_s
          )
        puts "brandSettledTakeBudgets size " + brandSettledTakeBudgets.size.to_s

        brandSettledTakeBudgets.each do |c|

          bTakeBudget = Statistics::BrandSettledTakeBudget.new
          bTakeBudget.tag = c.tag
          bTakeBudget.user_id = c.user_id

          bTakeBudget.total_campaign_count = c.total_campaign_count
          bTakeBudget.total_take_budget = c.total_take_budget
          bTakeBudget.deleted = 0
          bTakeBudget.created_at = Time.now
          bTakeBudget.updated_at = Time.now
          bTakeBudget.created_by = "system"
          bTakeBudget.updated_by = "system"

          ## result[result.length] = bTakeBudget
          bTakeBudget.save
        end

      end
      index = index + page_size
    end
    endTime = Time.new
    puts "End : " + result.length.to_s + " execution time " + (endTime - beginTime).to_s
  end
end
