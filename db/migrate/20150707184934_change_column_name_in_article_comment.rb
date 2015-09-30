class ChangeColumnNameInArticleComment < ActiveRecord::Migration
  def change
    rename_column :article_comments, :type, :comment_type
  end
end
