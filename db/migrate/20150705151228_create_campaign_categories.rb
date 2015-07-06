class CreateCampaignCategories < ActiveRecord::Migration
  def change
    create_table :campaign_categories do |t|
      t.belongs_to :campaign, :index => true
      t.string :iptc_category_id
    end
    add_index :campaign_categories, :iptc_category_id
  end
end
