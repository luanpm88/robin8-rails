class CreateRegisteredInvitations < ActiveRecord::Migration
  def change
    create_table :registered_invitations do |t|
      t.integer :inviter_id, index: true
      t.integer :invitee_id, index: true
      t.string  :mobile_number, index: true, limit: 191
      t.string  :status, index: true, limit: 191
      t.datetime :registered_at

      t.timestamps null: false
    end
  end
end
