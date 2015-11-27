class AddColumnsHasGrabedToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :has_grabed, :boolean, default: false
  end
end
