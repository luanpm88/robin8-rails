class SetDefaultValueForEffective < ActiveRecord::Migration
  def change
    change_column :download_invitations, :effective, :boolean, :default => false
  end
end
