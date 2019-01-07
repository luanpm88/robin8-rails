class CreateCreationTargets < ActiveRecord::Migration
  def change
    create_table :creation_targets do |t|
      t.string :targetable_type
      t.string :targetable_content
      t.integer :creation_id
      t.timestamps null: false
    end
  end
end
