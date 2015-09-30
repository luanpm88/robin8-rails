class ArticleCommentSerializer < ActiveModel::Serializer
  attributes :id, :text, :comment_type, :created_at, :sender
end
