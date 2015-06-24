class DeleteKolInterests < ActiveRecord::Migration
  def change
  	remove_column :kols, :interests, :string
  end
end
