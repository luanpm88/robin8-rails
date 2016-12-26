class AddColumnsManualInfoToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :user_id, :integer
    add_column :withdraws, :operate_admin, :string

    change_column :withdraws, :credits, :float
  end
end
