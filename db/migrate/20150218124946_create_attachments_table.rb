class CreateAttachmentsTable < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :url
      t.string :attachment_type
      t.references :imageable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
