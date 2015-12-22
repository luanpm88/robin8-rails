class AddStatusToCampains < ActiveRecord::Migration
  def change
    add_column :campaigns, :status, :string #unexecute,  rejected, agreed, executing,  executed
  end
end