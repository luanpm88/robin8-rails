class PostSerializer < ActiveModel::Serializer
  attributes :id, :text, :scheduled_date, :social_networks, :shrinked_links

  def scheduled_date
    object.scheduled_date.strftime('%H:%M %P')
  end

end