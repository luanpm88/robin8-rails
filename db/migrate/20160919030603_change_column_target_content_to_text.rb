class ChangeColumnTargetContentToText < ActiveRecord::Migration
  def change
    change_column :campaign_targets, :target_content, :text
  end
end
