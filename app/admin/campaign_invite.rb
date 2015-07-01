ActiveAdmin.register CampaignInvite do

  permit_params :status, :sent_at, :campaign_id, :kol_id

end
