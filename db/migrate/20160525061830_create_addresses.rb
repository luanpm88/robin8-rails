class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :addressable, polymorphic: true

      t.string :name
      t.string :phone
      t.string :postcode

      t.string :province
      t.string :city
      t.string :region
      t.string :location

      t.string :remark
    end
  end
end
