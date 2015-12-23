class RemoveCanDeleteFromIdentities < ActiveRecord::Migration
  def change
    remove_column :identities, :can_delete
  end
end
