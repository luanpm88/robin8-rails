class CampaignsSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :deadline, :budget, :created_at, :updated_at, :user, :tracking_code, :concepts, :summaries, :hashtags, :invite_status, :short_description, :content_type, :non_cash

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
end
