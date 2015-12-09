class CreateCampaignShows < ActiveRecord::Migration
  def change
    create_table :campaign_shows do |t|
      t.integer :campaign_id
      t.integer :kol_id
      t.text :visitor_cookie
      t.string :visitor_ip
      t.datetime :visit_time
      t.string :status
      t.string :remark

      t.timestamps null: false
    end
  end
end
