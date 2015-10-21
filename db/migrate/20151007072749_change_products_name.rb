class ChangeProductsName < ActiveRecord::Migration
  def up
    Product.all.each do |p|
      product_name = p.name
      if product_name.include? "Newsroom"
        product_name = product_name.gsub("Newsroom", "Brand Gallery")
      end
      if product_name.include? "Press Release Distribution"
        product_name = product_name.gsub("Press Release Distribution", "Content Distribution")
      end
      if product_name.include? "Release"
        product_name = product_name.gsub("Release", "Content")
      end
      if product_name.include? "releases"
        product_name = product_name.gsub("releases", "content")
      end
      if product_name.include? "release"
        product_name = product_name.gsub("release", "content")
      end
      if p.name != product_name
        p.update(:name => product_name)
        p.save
      end
    end
  end
end
