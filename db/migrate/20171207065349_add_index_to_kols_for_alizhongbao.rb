class AddIndexToKolsForAlizhongbao < ActiveRecord::Migration
  def up
    change_column :kols, :cid, :string, limit: 33
    change_column :kols, :channel, :string, limit: 33
    execute "ALTER TABLE kols MODIFY cid VARCHAR(33) CHARACTER SET utf8;"
    execute "ALTER TABLE kols MODIFY channel VARCHAR(33) CHARACTER SET utf8;"
    add_index :kols, [:cid]
    add_index :kols, [:channel]
  end

  def down
    remove_index :kols, [:cid]
    remove_index :kols, [:channel]
    execute "ALTER TABLE kols MODIFY cid VARCHAR(33) CHARACTER SET utf8mb4;"
    execute "ALTER TABLE kols MODIFY channel VARCHAR(33) CHARACTER SET utf8mb4;"
    change_column :kols, :cid, :string, limit: 255
    change_column :kols, :channel, :string, limit: 255
  end
end
