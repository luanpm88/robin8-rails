class AddStatusToCampains < ActiveRecord::Migration
  def change
    add_column :campaigns, :status, :string #unexecute,  executing,  executed
  end
end
