require 'rails_helper'

RSpec.describe "campaign_apply api" do
  before :each do
    @rich_user = FactoryGirl.create :rich_user
    @recruit_campaign = FactoryGirl.create(:recruit_campaign, user: @rich_user)
    @kol = FactoryGirl.create :kol
    @campaign_invite = FactoryGirl.create(:campaign_invite, campaign: @recruit_campaign, kol: @kol)
    @campaign_apply = FactoryGirl.create(:campaign_apply, campaign_invite: @campaign_invite, campaign: @recruit_campaign, kol: @kol)
    login_as(@rich_user, :scope => :user)
  end

  describe "PUT /brand_api/v1/campaign_applies/change_status" do
    it "change status to 'applying' if this campaign apply has been canceld and return 200" do
      @campaign_apply.update_attributes(status: "brand_passed")
      put "/brand_api/v1/campaign_applies/change_status", {campaign_id: @recruit_campaign.id, kol_id: @kol.id, operation: 'cancel'}
      expect(@campaign_apply.reload.status).to eq 'applying'
      expect(response.status).to eq 200
    end

    it "change status to 'brand_passed' if this campaign apply has been agreed and return 200" do
      put "/brand_api/v1/campaign_applies/change_status", {campaign_id: @recruit_campaign.id, kol_id: @kol.id, operation: 'agree'}
      expect(@campaign_apply.reload.status).to eq 'brand_passed'
      expect(response.status).to eq 200
    end

  end

  describe "Get all campaign applies" do
    it "return 200" do
      get "/brand_api/v1/campaign_applies", {campaign_id: @recruit_campaign.id}
      expect(response.status).to eq 200
    end
  end

end
