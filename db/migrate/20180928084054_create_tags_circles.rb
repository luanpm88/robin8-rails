class CreateTagsCircles < ActiveRecord::Migration
  def change
    create_table :tags_circles do |t|
      t.belongs_to :tag
      t.belongs_to :circle
      t.timestamps null: false
    end
  end
end
