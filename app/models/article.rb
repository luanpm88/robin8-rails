require 'digest'

class Article < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :kol
  has_many :article_comments
  has_many :attachments, as: :imageable, dependent: :destroy

  def approve
    if tracking_code.nil?
      sha1 = Digest::SHA1.new
      campaign = campaign_id
      kol = kol_id
      article = id
      self.tracking_code = sha1.hexdigest "#{article}_#{campaign}_#{kol}_#{Time.now}"
      save!
    end
    tracking_code
  end
end
