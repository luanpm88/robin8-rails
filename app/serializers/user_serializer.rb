class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :first_name, :last_name, :company, :newsroom_available_count,
    :can_create_newsroom, :newsroom_count, :release_count, :can_create_release, :release_available_count,
    :can_create_stream, :can_create_smart_release, :recurring_add_ons, :can_create_seat,
    :smart_release_available_count

  has_many :user_features
  has_many :news_rooms

end
