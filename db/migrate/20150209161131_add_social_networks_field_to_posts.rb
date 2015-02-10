class AddSocialNetworksFieldToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :social_networks, :text
  end
end
