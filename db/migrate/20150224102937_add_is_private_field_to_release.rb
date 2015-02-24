class AddIsPrivateFieldToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :is_private, :boolean, default: false
    add_column :releases, :logo_url, :string
  end
end
