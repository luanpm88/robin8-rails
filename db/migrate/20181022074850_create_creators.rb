class CreateCreators < ActiveRecord::Migration
  def change
    create_table :creators do |t|
      t.float :price, default: 0.0
      t.integer :fans_count
      t.integer :gender
      t.integer :age_range
      t.string :content_show
      t.string :remark
      t.integer :status, default: 0
      t.belongs_to :kol
      t.timestamps null: false
    end
  end
end
