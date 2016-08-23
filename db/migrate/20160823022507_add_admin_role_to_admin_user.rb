class AddAdminRoleToAdminUser < ActiveRecord::Migration
  def change
    admin = AdminUser.where(email: "admin@admin.com").first
    admin.add_role :admin
  end
end
