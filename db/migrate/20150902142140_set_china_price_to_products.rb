class SetChinaPriceToProducts < ActiveRecord::Migration
  def change
    Product.all.each do |p|
      p.update(:china_price => p.price/2)
      p.save
    end
  end
end
