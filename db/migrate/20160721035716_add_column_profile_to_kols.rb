class AddColumnProfileToKols < ActiveRecord::Migration
  def change
    add_column :kols, :profession, :string
    add_column :kols, :brief, :text
  end
end
