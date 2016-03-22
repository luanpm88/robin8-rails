class AddUtmSourceToKols < ActiveRecord::Migration
  def change
    add_column :kols, :utm_source, :string
  end
end
