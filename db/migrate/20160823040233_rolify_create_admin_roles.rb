class RolifyCreateAdminRoles < ActiveRecord::Migration
  def change
    create_table(:admin_roles) do |t|
      t.string   :name, limit: 100
      t.integer  :resource_id
      t.string   :resource_type, limit: 100
      t.timestamps
    end

    create_table(:admin_users_admin_roles, :id => false) do |t|
      t.references :admin_user
      t.references :admin_role
    end

    add_index(:admin_roles, :name)
    add_index(:admin_roles, [ :name, :resource_type, :resource_id ])
    add_index(:admin_users_admin_roles, [ :admin_user_id, :admin_role_id ])

    admin = AdminUser.where(email: "admin@admin.com").first
    admin.add_role :admin
  end
end
