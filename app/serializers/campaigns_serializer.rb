class CampaignsSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :deadline, :budget, :created_at, :updated_at, :user, :tracking_code, :concepts, :summaries, :hashtags, :invite_status, :short_description, :content_type, :non_cash, :iptc_categories, :interested, :campaign_action_urls

  def tracking_code
    if not scope.nil?
      article = object.articles.where(kol_id: scope.id).first
      if not article.nil?
        return article.tracking_code
      end
    end
    nil
  end
  def invite_status
    if not scope.nil? && @options[:campaign_status].nil?
      if @options[:campaign_status] != 'accepted'
        campaign_invite = object.campaign_invites.where(kol_id: scope.id).first
        if not campaign_invite.nil?
          return campaign_invite.status
        end
      end
    end
    nil
  end
  def iptc_categories
    campaign_categories = Campaign.find(id).campaign_categories
    if not campaign_categories.nil? and campaign_categories.length > 0
      labels = []
      campaign_categories.each do |category|
        labels =  IptcCategory.where(:id => category.iptc_category_id).map(&:label)
      end
      return labels.join(',')
    end
    ""
  end
  def interested
    if not scope.nil? && @options[:campaign_status].nil?
      campaign_interested = []
      campaign_interested = InterestedCampaign.where(:campaign_id => id, :kol_id => scope.id)
      return campaign_interested
    end
    nil
  end
  def campaign_action_urls
    return object.campaign_action_urls
  end
end
