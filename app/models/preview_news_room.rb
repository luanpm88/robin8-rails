class PreviewNewsRoom < ActiveRecord::Base
  self.table_name = "news_rooms"
  default_scope { where.not(parent_id: nil) }
  belongs_to :news_room, :class_name => 'NewsRoom', :foreign_key => 'parent_id'

  def city_state
    str = [city, state]
    str.reject! { |c| c.blank? }
    str.join(', ')
  end

  def location
    str = [address_1, postal_code, city, state, country]
    str.reject! { |c| c.blank? }
    str.join(', ')
  end

  def has_contact_info?
    [address_1, postal_code, city, state, country, web_address, email].reject(&:blank?).length > 0
  end

  def has_social_links?
    [facebook_link, twitter_link, linkedin_link, instagram_link].reject(&:blank?).length > 0
  end

  def attachments
    NewsRoom.find(self.parent_id).attachments
  end

end