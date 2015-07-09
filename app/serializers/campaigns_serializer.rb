class CampaignsSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :deadline, :budget, :created_at, :updated_at, :user, :tracking_code

  def tracking_code
    if not scope.nil?
      article = object.articles.where(kol_id: scope.id).first
      return article.tracking_code
    end
    nil
  end
end
