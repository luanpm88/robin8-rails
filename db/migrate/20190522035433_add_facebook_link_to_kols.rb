class AddFacebookLinkToKols < ActiveRecord::Migration
  def change
    add_column :kols, :facebook_link, :string
  end
end
