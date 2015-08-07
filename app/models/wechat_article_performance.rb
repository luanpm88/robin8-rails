class WechatArticlePerformance < ActiveRecord::Base
  belongs_to :sender, polymorphic: true
  belongs_to :article
  has_many :attachments, as: :imageable, dependent: :destroy
end
