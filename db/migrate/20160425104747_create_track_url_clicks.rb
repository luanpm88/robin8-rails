class CreateTrackUrlClicks < ActiveRecord::Migration
  def change
    create_table :track_url_clicks do |t|
      t.references :track_url
      t.string     :cookie
      t.string     :refer
      t.string     :user_agent
      t.string     :vistor_ip
      t.timestamps null: false
    end
  end
end
