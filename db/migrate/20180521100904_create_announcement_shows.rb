class CreateAnnouncementShows < ActiveRecord::Migration
  def change
    create_table :announcement_shows do |t|
    	t.string :params_json

    	t.references :kol
    	t.references :announcement

      t.timestamps null: false
    end
  end
end
