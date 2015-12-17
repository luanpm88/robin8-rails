class AddProviderColumnToKol < ActiveRecord::Migration
  def change
    add_column :kols, :provider, :string, :default => "signup"
  end
end
