class AddColumnShareAndReadToKolInfluenceValue < ActiveRecord::Migration
  def change
    add_column :kol_influence_values, :share_times, :integer, :default => 0
    add_column :kol_influence_values, :read_times, :integer, :default => 0
  end
end
