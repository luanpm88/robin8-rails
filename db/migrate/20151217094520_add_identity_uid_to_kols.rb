class AddIdentityUidToKols < ActiveRecord::Migration
  def change
    add_column :kols, :social_uid, :string
  end
end
