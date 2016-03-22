class AddColumnQqProfileToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :province, :string
    add_column :identities, :city, :string
    add_column :identities, :gender, :string
    add_column :identities, :is_vip, :boolean
    add_column :identities, :is_yellow_vip, :boolean

    add_column :tmp_identities, :province, :string
    add_column :tmp_identities, :city, :string
    add_column :tmp_identities, :gender, :string
    add_column :tmp_identities, :is_vip, :boolean
    add_column :tmp_identities, :is_yellow_vip, :boolean
  end
end
