class AddKolLocale < ActiveRecord::Migration
  def change
    add_column :kols, :locale, :string
  end
end
