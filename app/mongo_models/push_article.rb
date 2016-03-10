class PushArtile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kol_id, type: Integer
  field :article_id, type: String
  field :article_url, type: String
  field :article_logo_url, type: String
  field :article_title, type: String
  field :article_url, type: String

  validates :kol_id, presence: true
  validates :article_id, presence: true
end
