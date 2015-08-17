class CreateWeibos < ActiveRecord::Migration
  def change
    create_table :weibos do |t|
      t.integer :pressr_id, :limit => 8
      t.string :first_name
      t.string :last_name
      t.string :full_name
      t.string :email

      t.timestamps null: false
    end
  end
end
