class AddColumnToCpsMaterials < ActiveRecord::Migration
  def change
    add_column :cps_materials, :is_hot, :boolean, :default => false

    CpsMaterial.update_all(:is_hot => true)
  end
end
