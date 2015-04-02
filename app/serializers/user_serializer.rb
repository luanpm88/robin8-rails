class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :first_name, :last_name, :company, :newsroom_available_count,
    :can_create_newsroom, :newsroom_count

  has_many :user_features
  has_many :news_rooms

  def can_create_newsroom
    newsroom_count < newsroom_available_count
  end

end
