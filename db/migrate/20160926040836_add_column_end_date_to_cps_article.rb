class AddColumnEndDateToCpsArticle < ActiveRecord::Migration
  def change
    add_column :cps_articles, :end_date, :datetime
  end
end
