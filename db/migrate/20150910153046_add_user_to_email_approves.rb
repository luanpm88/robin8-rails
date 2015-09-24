class AddUserToEmailApproves < ActiveRecord::Migration
  def change
    add_column :email_approves, :user_id, :integer
  end
end
