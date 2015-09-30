class AddKolFields < ActiveRecord::Migration
  def change
    add_column :kols, :gender, :integer, :default => 0
    add_column :kols, :country, :string
    add_column :kols, :province, :string
    add_column :kols, :city, :string
    add_column :kols, :audience_age_min, :integer, :default => 0
    add_column :kols, :audience_age_max, :integer, :default => 100
    add_column :kols, :audience_gender_ratio, :string, :default => 0
    add_column :kols, :audience_city_level, :string, :default => 0
  end
end
