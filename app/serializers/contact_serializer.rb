class ContactSerializer < ActiveModel::Serializer
  attributes :id, :author_id, :first_name, :last_name, :email, :twitter_screen_name
end
