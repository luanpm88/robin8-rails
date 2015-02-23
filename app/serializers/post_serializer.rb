class PostSerializer < ActiveModel::Serializer
  attributes :id, :text, :scheduled_date, :social_networks, :shrinked_links, :formamtted_scheduled_date

  def formamtted_scheduled_date
    object.scheduled_date.strftime('%H:%M %P')
  end

  def scheduled_date
    object.scheduled_date.strftime("%m/%d/%Y %I:%M %p")
  end

end