class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :title
      t.string :logo
      t.string :banner
      t.string :desc
      t.boolean :display, :default => false
      t.integer :position, :default => 0
      t.string :url

      t.timestamps null: false
    end
  end
end
