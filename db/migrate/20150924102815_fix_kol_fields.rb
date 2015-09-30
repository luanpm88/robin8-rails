class FixKolFields < ActiveRecord::Migration
  def change
    add_column :kols, :audience_age_groups, :string, :default => ""
    remove_column :kols, :audience_age_min
    remove_column :kols, :audience_age_max
  end
end
