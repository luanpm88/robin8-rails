class AddColumnAbountPriceToIdenties < ActiveRecord::Migration
  def change
    add_column :identities, :avatar_url, :string
    add_column :identities, :desc, :string

    add_column :identities, :audience_age_groups, :string
    add_column :identities, :audience_gender_ratio, :string
    add_column :identities, :audience_regions, :string

    add_column :identities, :edit_forward, :decimal, :precision => 8, :scale => 2
    add_column :identities, :origin_publish, :decimal, :precision => 8, :scale => 2
    add_column :identities, :forward, :decimal, :precision => 8, :scale => 2
    add_column :identities, :origin_comment, :decimal, :precision => 8, :scale => 2
    add_column :identities, :partake_activity, :decimal, :precision => 8, :scale => 2
    add_column :identities, :panel_discussion, :decimal, :precision => 8, :scale => 2
    add_column :identities, :undertake_activity, :decimal, :precision => 8, :scale => 2
    add_column :identities, :image_speak, :decimal, :precision => 8, :scale => 2
    add_column :identities, :give_speech, :decimal, :precision => 8, :scale => 2
  end
end
