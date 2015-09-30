class CreateCampaignInvites < ActiveRecord::Migration
  def change
    create_table :campaign_invites do |t|
      t.string :status
      t.belongs_to :campaign, index: true
      t.belongs_to :kol, index: true

      t.timestamps null: false
    end
    add_index :campaign_invites, :status
  end
end
