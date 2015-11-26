class ChangeColumnForPrice < ActiveRecord::Migration
  def change
    change_column :identities, "edit_forward",      :integer
    change_column :identities, "origin_publish",    :integer
    change_column :identities,  "forward",          :integer
    change_column :identities,  "origin_comment",   :integer
    change_column :identities,  "partake_activity", :integer
    change_column :identities,  "panel_discussion", :integer
    change_column :identities,  "undertake_activity",  :integer
    change_column :identities,  "image_speak",         :integer
    change_column :identities,  "give_speech",          :integer
  end
end
