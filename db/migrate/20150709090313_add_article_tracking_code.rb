class AddArticleTrackingCode < ActiveRecord::Migration
  def change
    add_column :articles, :tracking_code, :string
  end
end
