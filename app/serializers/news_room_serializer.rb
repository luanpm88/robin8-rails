class NewsRoomSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :company_name, :room_type, :size, :email, :phone_number, :fax, :web_address,
      :description, :address_1, :address_2, :city, :state, :postal_code, :country, :owner_name, :toll_free_number,
      :job_title, :facebook_link, :twitter_link, :linkedin_link, :instagram_link, :tags, :subdomain_name, :logo_url,
      :default_news_room, :publish_on_website, :releases_count

  has_many :industries, embed: :ids
  has_many :attachments

  def releases_count
    object.releases.size
  end
end
