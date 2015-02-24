class AddColumnExpiryToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions,:expiry,:date
    add_column :subscriptions,:cancelled_at,:datetime
  end
end
