class Statistics::CampaignSettledTakeBudget < ActiveRecord::Base
  
  def self.calculate_campaign_settled_take_budget(tag_name)
    adminTag = Admintag.find_by(tag: tag_name)
    puts "admin tag " + adminTag.tag

    beginTime = Time.new
    page_size = 30
    index = 0
    total = Campaign.count

    result = Array.new
    loop do
      puts "Looking records for Campaign page size : " + page_size.to_s + " index at: " + index.to_s
      campaign_count = Campaign.joins(kols: :admintags).where("admintags.tag=?", adminTag.tag).order(id: :asc).uniq(:id).count
      puts ">>>>>>>>>>> c count " + campaign_count.to_s

      if index > campaign_count
        # no record anymore
        break
      else

        campaigns = Campaign.joins(kols: :admintags).where("admintags.tag=?", adminTag.tag).order(id: :asc).uniq(:id).limit(page_size).offset(index)
        puts "block size " + campaigns.size.to_s

        campaigns.each do |c|
          puts "campaign id " + c.id.to_s
          valid_count = c.campaign_shows_by_tag(adminTag).valid.count
          take_budget = c.per_action_budget * valid_count
          cTakeBudget = Statistics::CampaignSettledTakeBudget.new
          cTakeBudget.campaign_id = c.id
          take_budget = c.take_budget
          puts "take budget for c id " + c.id.to_s + " take budget :" + take_budget.to_s
          cTakeBudget.take_budget = take_budget
          cTakeBudget.user_id = c.user_id
          cTakeBudget.tag = adminTag.tag
          cTakeBudget.deleted = 0
          cTakeBudget.created_at = Time.now
          cTakeBudget.updated_at = Time.now
          cTakeBudget.created_by = "system"
          cTakeBudget.updated_by = "system"
          result[result.length] = cTakeBudget
          cTakeBudget.save
        end

      end
      index = index + page_size
    end
    endTime = Time.new
    puts "End : " + result.length.to_s + " execution time " + (endTime - beginTime).to_s
    # result.each do |e|
    #   #   puts " result ==> user id " + e.user_id.to_s + " campaign id " + e.campaign_id.to_s + " take budget " + e.take_budget.to_s
    # end
  end
  
end
