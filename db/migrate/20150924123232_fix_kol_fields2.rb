class FixKolFields2 < ActiveRecord::Migration
  def change
    add_column :kols, :audience_regions, :string, :default => ""
    remove_column :kols, :audience_city_level
  end
end
