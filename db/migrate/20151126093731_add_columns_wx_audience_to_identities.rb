class AddColumnsWxAudienceToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :audience_likes, :string
    add_column :identities, :audience_friends, :string
    add_column :identities, :audience_talk_groups, :string
    add_column :identities, :audience_publish_fres, :string

  end
end
