class CreateCampaignInvites < ActiveRecord::Migration
  def change
    create_table :campaign_invites do |t|
      t.string :status
      t.datetime :sent_at
      t.belongs_to :campaign, index: true
      t.belongs_to :kols, index: true

      t.timestamps null: false
    end
  end
end
