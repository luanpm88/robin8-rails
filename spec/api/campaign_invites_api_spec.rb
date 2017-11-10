require 'rails_helper'

RSpec.describe "campaign_invite api" do
  before :each do
    @rich_user = FactoryGirl.create :rich_user
    @recruit_campaign = FactoryGirl.create(:recruit_campaign, user: @rich_user)
    @kol = FactoryGirl.create :kol
    @campaign_invite = FactoryGirl.create(:campaign_invite, campaign: @recruit_campaign, kol: @kol)
    @campaign_apply = FactoryGirl.create(:campaign_apply, campaign_invite: @campaign_invite, campaign: @recruit_campaign, kol: @kol)
    login_as(@rich_user, :scope => :user)
  end

  describe "GET /brand_api/v1/campaign_invites" do
    it "return 200" do
      get "/brand_api/v1/campaign_invites?campaign_id=#{@recruit_campaign.id}"
      expect(response.status).to eq 200
    end

    xit "return campaign_invites" do
      get "/brand_api/v1/campaign_invites?campaign_id=#{@recruit_campaign.id}"

      pattern = {
        items: [{
          id: Integer,
          get_avail_click: Integer,
          get_total_click: Integer,
          screenshot: "www.baidu.com",
          img_status: "pending",
          kol: {id: Integer, name: String, avatar_url: wildcard_matcher, influence_score: 701.0, city: "上海"},
          campaign: Hash,
          campaign_apply_status: "platform_passed",
          agree_reason: "test"
        }],
        paginate: Hash
      }

      expect(response.body).to match_json_expression pattern

    end

  end
end
