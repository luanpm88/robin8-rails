class AddColumnsAliasUnionidToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :alias, :string
    add_column :identities, :unionid, :string
  end
end
