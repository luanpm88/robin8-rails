class SetDefaultGenderRatio < ActiveRecord::Migration
  def change
    Kol.all.each do |k|
      k.audience_gender_ratio = '50:50'
      k.save
    end
    change_column :kols, :audience_gender_ratio, :string, :default => '50:50'
  end
end
