require 'rails_helper'

RSpec.describe "campaign invites api" do
  before :each do
    @rich_user = FactoryGirl.create :rich_user
    @recruit_campaign = FactoryGirl.create(:recruit_campaign, user: @rich_user)
    @kol = FactoryGirl.create :kol
    @campaign_invite = FactoryGirl.create(:campaign_invite, campaign: @recruit_campaign, kol: @kol)
    @campaign_apply = FactoryGirl.create(:campaign_apply, campaign: @recruit_campaign, kol: @kol)
    @campaign_invite.campaign_apply_id = @campaign_apply.id
    login_as(@rich_user, :scope => :user)
  end

  describe "GET /brand_api/v1/campaign_invites" do
    it "return 200" do
      get "/brand_api/v1/campaign_invites?campaign_id=#{@recruit_campaign.id}"
      binding.pry
      expect(response.status).to eq 200
    end
  end

  # promise: fetch(`${baseUrl}/campaign_invites?campaign_id=${campaign_id}&page=${current_page.page}`, {'credentials': 'include'})


end

# get "/" do
#   # 需要考虑 以管理员的身份 查看 campaign 详情的 需求
#   campaign = Campaign.find_by :id => params[:campaign_id], :user_id => current_user.id
#   campaign_invites = paginate(Kaminari.paginate_array(campaign.valid_invites({:include => :kol })))
#   present campaign_invites
# end
