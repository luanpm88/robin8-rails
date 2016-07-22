class AddColumnProfileToKols < ActiveRecord::Migration
  def change
    add_column :kols, :profession, :string
    add_column :kols, :brief, :text
    add_column :kols, :kol_role, :string
    add_column :kols, :role_apply_status, :string
  end
end
