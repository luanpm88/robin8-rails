class AddSlugToAddOns < ActiveRecord::Migration
  def migrate(direction)
    super
    if direction == :up
      if defined?(AddOn)
        AddOn.all.each do |a|
          a.create_slug
        end
      end
    end
  end
  def change
    add_column :add_ons,:slug,:string
  end
end
