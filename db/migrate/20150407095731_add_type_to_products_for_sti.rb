class AddTypeToProductsForSti < ActiveRecord::Migration
  def migrate(direction)
    super
    Product.all.each do |p|
      p.is_package? ? p.update_attribute(:type, "Package") : p.update_attribute(:type,"AddOn")
    end if direction == :up
  end

  def change
    add_column :products,:type,:string
  end
end
