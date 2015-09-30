class AddIsPublicKolField < ActiveRecord::Migration
  def change
    add_column :kols, :is_public, :boolean, default: true
  end
end
