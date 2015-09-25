class AddKolAvatarField < ActiveRecord::Migration
  def change
    add_column :kols, :avatar_url, :string
  end
end
