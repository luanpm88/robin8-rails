class AddKolStats < ActiveRecord::Migration
  def change
    add_column :kols, :stats_total, :integer, :default => 0
    add_column :kols, :stats_total_changed, :datetime
  end
end
