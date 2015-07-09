class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :text, :created_at, :updated_at, :kol, :article_comments, :tracking_code
end
