class AddEmailTwitterTargetsToPitches < ActiveRecord::Migration
  def change
    add_column :pitches, :email_targets, :boolean, default: false
    add_column :pitches, :twitter_targets, :boolean, default: false
  end
end
