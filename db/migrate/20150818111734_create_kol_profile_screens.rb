class CreateKolProfileScreens < ActiveRecord::Migration
  def change
    create_table :kol_profile_screens do |t|
      t.string :url
      t.string :name
      t.string :thumbnail
      t.belongs_to :kol
      t.string :social_name

      t.timestamps null: false
    end
  end
end
