class Carticle < ActiveRecord::Base
  after_save :create_article
  def create_article
    unless self.body_changed?
      return
    end
    splits = self.body.split(/(<img>)|(<\/img>)|(<product>)|(<\/product>)/)
    index = 0
    body_html = []
    while true
      if index > splits.count
        break
      end

      item = splits[index]
      if item.blank?
        index = index + 1
        next
      end
      if item == "<img>"
        body_html << ['img', splits[index+1] ]
        index = index + 3
        next
      end

      if item == "<product>"
        body_html << ['product', splits[index+1]]
        index = index + 3
        next
      end

      body_html << ["text", item]
      index = index + 1
    end
    Rails.cache.write(cps_content_key, body_html, :expires_in => 1.months)
  end

  def cps_content_key
    "cps_content_key_#{self.id}"
  end

  def get_formated_content
    formated_content = Rails.cache.fetch cps_content_key
    if formated_content.blank?
      create_article
      formated_content = Rails.cache.fetch cps_content_key
    end
    formated_content
  end
end
