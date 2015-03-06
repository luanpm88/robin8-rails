class AddAttachmentToMediaLists < ActiveRecord::Migration
  def self.up
    add_attachment :media_lists, :attachment
  end

  def self.down
    remove_attachment :media_lists, :attachment
  end
end
