class AddRejectReasonToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :reject_reason, :string
  end
end
