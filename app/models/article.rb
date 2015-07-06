class Article < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :kol
  has_many :article_comments
end
