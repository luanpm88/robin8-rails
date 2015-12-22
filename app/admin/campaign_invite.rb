ActiveAdmin.register CampaignInvite do

  actions :all, :except => [:destroy]

  permit_params :status, :sent_at, :campaign_id, :kol_id

end
