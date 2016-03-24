class AddColumnEnmuActionsToArticleAction < ActiveRecord::Migration
  def change
    add_column :article_actions, :uuid, :string

    add_column :article_actions, :look, :boolean, :default => false
    add_column :article_actions, :forward, :boolean, :default => false
    add_column :article_actions, :collect, :boolean, :default => false
    add_column :article_actions, :like, :boolean, :default => false
  end
end
