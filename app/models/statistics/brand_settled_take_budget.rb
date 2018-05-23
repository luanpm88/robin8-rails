class Statistics::BrandSettledTakeBudget < ActiveRecord::Base
  def self.calculate_brand_settled_take_budget(tag_name)
    adminTag = Admintag.find_by(tag: tag_name)
    page_size = 100
    index = 0
    total = Campaign.count

    result = Array.new
    loop do
      puts "Looking records for Campaign page size : " + page_size.to_s + " index at: " + index.to_s
      brand_count = StatCampaignSettledTakeBudget
      .find_by_sql("select user_id, tag, count(id) as total_campaign_count,
sum(take_budget) as total_take_budget from stat_campaign_settled_take_budget group by user_id, tag").count
#        .select("user_id, count(id) as total_campaign_count, sum(take_budget) as total_take_budget")
 #                     .group("tag, user_id").order("total_take_budget desc").limit(page_size).offset(index)
                   #   .count

      puts "brand count " + brand_count.to_s
      break
      brand_count = Campaign.order("id").limit(page_size).offset(index).count
      if campaign_count == 0
        # no record anymore
        break
      else
        campaigns = Campaign.order("id").limit(page_size).offset(index)
        campaigns.each do |c|
          puts "c id " + c.id.to_s
          take_budget = c.take_budget
          cTakeBudget = Statistics::BrandSettledTakeBudget.new(c.id, take_budget, c.user_id)
          result[result.length] = cTakeBudget;

        end
      end
      index = index + page_size
    end
    puts "End : " + result.length.to_s
    result.each do |e|
      puts " result ==> user id " + e.user_id.to_s + " campaign id " + e.campaign_id.to_s + " take budget " + e.take_budget
    end

      # Campaign.order("id").limit(page_size).offset(index).
    # Campaign.all.where("id < 10").map(&:id).each do |c|
    #   puts "c id= " + c.id.to_s
    # end


  end
end
