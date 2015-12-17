class AddProviderColumnToKol < ActiveRecord::Migration
  def change
    add_column :kols, :provider, :string, :default => "signup"
    add_column :kols, :uid, :string
  end
end
