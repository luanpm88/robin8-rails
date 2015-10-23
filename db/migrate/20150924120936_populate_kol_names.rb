class PopulateKolNames < ActiveRecord::Migration
  def change
    Kol.all.each do |k|
      k.name = "#{k.first_name} #{k.last_name}"
      k.save
    end
  end
end
