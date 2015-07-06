class ArticleComment < ActiveRecord::Base
  belongs_to :sender, polymorphic: true
  belongs_to :article
end
