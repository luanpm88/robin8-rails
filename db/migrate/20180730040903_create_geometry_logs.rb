class CreateGeometryLogs < ActiveRecord::Migration
  def change
    create_table :geometry_logs do |t|
      t.string :mobile
      t.string :_action, null: false
      t.belongs_to :resource, :polymorphic => true
      t.text :opts
      t.timestamps null: false
    end
  end
end
