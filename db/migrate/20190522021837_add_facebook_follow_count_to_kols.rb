class AddFacebookFollowCountToKols < ActiveRecord::Migration
  def change
    add_column :kols, :facebook_follow_count, :integer
  end
end
