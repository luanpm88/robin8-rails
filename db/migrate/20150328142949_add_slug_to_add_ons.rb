class AddSlugToAddOns < ActiveRecord::Migration
  def migrate(direction)
    super
    if direction == :up
      AddOn.all.each do |a|
        a.create_slug
      end
    end
  end
  def change
    add_column :add_ons,:slug,:string
  end
end
