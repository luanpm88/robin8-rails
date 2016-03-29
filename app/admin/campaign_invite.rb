ActiveAdmin.register CampaignInvite do
  remove_filter :kol


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
      if my_resource.campaign
        my_resource.campaign.name
      end
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
    column :img_status
    actions do |my_resource|
      if my_resource.campaign.status != "settled" && my_resource.img_status == "pending" && my_resource.screenshot.present? && (my_resource.campaign.deadline > (Time.now - Campaign::SettleWaitTimeForBrand))
        (link_to '审核', show_verify_page_admin_campaign_invite_path(my_resource.id), :method => :get, :target => "_blank" )
      elsif my_resource.img_status == "passed"
        '已通过'
      elsif my_resource.img_status == "rejected"
        '已拒绝'
      else
        '未上传'
      end
    end
  end

end
