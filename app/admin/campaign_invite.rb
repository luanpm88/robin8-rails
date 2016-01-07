ActiveAdmin.register CampaignInvite do

  before_filter :only => [:index] do
    params['q'] = {:status_eq => 'finished'}
  end

  actions :all, :except => [:destroy]

  permit_params :status, :total_click, :avail_click, :uuid, :share_url

  member_action :show_verify_page, :method => :get do

  end

  member_action :operate, :method => :put do

  end

  controller do
    def show_verify_page
      @campaign_invite = CampaignInvite.find(params[:id])
    end

    def operate
      @campaign_invite = CampaignInvite.find(params[:id])
    end
  end

  index do
    selectable_column
    id_column

    column "Campaign name" do |my_resource|
      my_resource.campaign.name
    end

    column "kol name" do |my_resource|
      kol = my_resource.kol
      if kol
        if kol.email
          kol.email
        elsif kol.provider != 'signup'
          kol.social_name
        else
          "未命名"
        end
      end
    end

    column :total_click
    column :avail_click
    column :approved_at
    column :status
    actions do |my_resource|
      if my_resource.img_status == "passed"
        (link_to '审核通过', show_verify_page_admin_campaign_invite_path(my_resource.id), :method => :get )
      else
        if my_resource.status == "finished" && my_resource.img_status == "pending" && my_resource.screenshot.present?
          (link_to '截图审核', show_verify_page_admin_campaign_invite_path(my_resource.id), :method => :get )
        end
      end
    end
  end

end
