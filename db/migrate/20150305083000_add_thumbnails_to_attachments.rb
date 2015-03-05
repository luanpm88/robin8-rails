class AddThumbnailsToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :thumbnail, :string
  end
end
