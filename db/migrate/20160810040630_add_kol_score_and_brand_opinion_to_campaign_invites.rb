class AddKolScoreAndBrandOpinionToCampaignInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :kol_score, :string
    add_column :campaign_invites, :brand_opinion, :string
  end
end
