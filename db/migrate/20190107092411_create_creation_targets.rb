class CreateCreationTargets < ActiveRecord::Migration
  def change
    create_table :creation_targets do |t|
      t.references :targetable, polymorphic: true
      t.string :addressable_content
      t.timestamps null: false
    end
  end
end
