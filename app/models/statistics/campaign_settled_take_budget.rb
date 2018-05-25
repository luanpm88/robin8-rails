class Statistics::CampaignSettledTakeBudget < ActiveRecord::Base
  
  
  def self.calculate_campaign_settled_take_budget_daily 
    
    adminTag = Admintag.find_by_tag "geometry"
    
    beginTime = Time.new #FIXME
    page_size = 30
    index = 0
    total = Campaign.count
    
    self.delete_all 
    
    result = Array.new
    loop do
      # may have issue, the campaign payment status is not set
      # status = settled << should check 
      # duplicate count?
      campaign_count = Campaign.joins(kols: :admintags).where("admintags.tag=?", adminTag.tag).order(id: :asc).uniq(:id).count
      
      if index > campaign_count
        # no record anymore
        break
      else

        campaigns = Campaign.joins(kols: :admintags).where("admintags.tag=?", adminTag.tag).order(id: :asc).uniq(:id).limit(page_size).offset(index)
        
        campaigns.each do |c|
          
          valid_count = c.campaign_shows_by_tag(adminTag).valid.count
          take_budget = c.per_action_budget * valid_count
          cTakeBudget = Statistics::CampaignSettledTakeBudget.new
          cTakeBudget.campaign_id = c.id
          take_budget = c.take_budget
          
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
    Statistics::BrandSettledTakeBudget.calculate_brand_settled_take_budget()
  end
end
