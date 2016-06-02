class AddIndexPrivateTokenToKols < ActiveRecord::Migration
  def change
    change_column :kols, :private_token, :string, :limit => 80
    add_index :kols, :private_token
  end
end
