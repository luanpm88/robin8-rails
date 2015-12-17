class AddCanDeleteColumnToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :can_delete, :boolean, default: true
  end
end
