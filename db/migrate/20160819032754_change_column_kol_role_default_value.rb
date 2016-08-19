class ChangeColumnKolRoleDefaultValue < ActiveRecord::Migration
  def change
    change_column :kols, :kol_role, :string, :default => 'public', :limit => 80
    Kol.where("kol_role is null").update_all(:kol_role => 'public')
  end
end
