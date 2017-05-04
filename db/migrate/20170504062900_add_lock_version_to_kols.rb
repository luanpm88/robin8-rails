class AddLockVersionToKols < ActiveRecord::Migration
  def change
    add_column :kols, :lock_version, :integer, default: 1
  end
end
