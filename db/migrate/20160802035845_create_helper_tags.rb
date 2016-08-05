class CreateHelperTags < ActiveRecord::Migration
  def change
    create_table :helper_tags do |t|
      t.string   :title
      t.timestamps null: false
    end
  end
end
