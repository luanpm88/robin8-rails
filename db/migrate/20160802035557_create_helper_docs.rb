class CreateHelperDocs < ActiveRecord::Migration
  def change
    create_table :helper_docs do |t|
      t.string     :img_url
      t.string     :question
      t.text       :answer
      t.references :helper_tag
      t.integer    :sort_weight, default: 100
      t.timestamps null: false
    end
  end
end
