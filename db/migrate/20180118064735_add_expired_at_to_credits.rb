class AddExpiredAtToCredits < ActiveRecord::Migration
  def change
  	add_column :credits, :expired_at, :datetime
  end
end