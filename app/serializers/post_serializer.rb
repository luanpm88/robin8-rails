class PostSerializer < ActiveModel::Serializer
  attributes :id, :text, :scheduled_date, :shrinked_links, :formamtted_scheduled_date, :created_at,
             :facebook_ids, :twitter_ids, :linkedin_ids

  def formamtted_scheduled_date
    object.scheduled_date.strftime('%I:%M %P')
  end

  def scheduled_date
    object.scheduled_date.strftime("%m/%d/%Y %I:%M %p")
  end

end