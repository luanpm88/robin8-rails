class AddColumnShowCountToKols < ActiveRecord::Migration
  def change
    add_column :kols, :show_count, :Integer, :default => 30
  end
end
