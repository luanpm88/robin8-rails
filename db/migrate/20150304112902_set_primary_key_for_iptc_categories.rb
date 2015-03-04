class SetPrimaryKeyForIptcCategories < ActiveRecord::Migration
  #mysql specific migration
  def up
    execute "ALTER TABLE iptc_categories ADD PRIMARY KEY (id);"
  end
  
  def down
    execute "ALTER TABLE iptc_categories DROP PRIMARY KEY;"
  end
end
