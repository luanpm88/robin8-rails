require 'rails_helper'

RSpec.describe Brand::V1::CampaignsAPI do
  before :each do
    rich_user = FactoryGirl.create :rich_user
    @campaign = FactoryGirl.create(:campaign, user: rich_user)

    login_as(rich_user, :scope => :user)
  end

  describe 'GET /brand_api/v1/campaigns/:id', :type => :feature do
    it 'returns 200' do
      get "/brand_api/v1/campaigns/#{@campaign.id}"

      expect(response.status).to eq 200
    end

    it 'returns campaign' do
      get "/brand_api/v1/campaigns/#{@campaign.id}"

      pattern = {
        id: Integer,
        name: String,
        description: String,
        short_description: wildcard_matcher,
        img_url: wildcard_matcher,
        status: String,
        user: Hash,
        message: wildcard_matcher,
        url: String,
        budget: Fixnum,
        per_budget_type: String,
        per_action_budget: Float,
        deadline: String,
        start_time: String,
        avail_click: Fixnum,
        total_click: Fixnum,
        fee_info: String,
        share_time: Integer,
        take_budget: Float,
        remain_budget: Float,
        created_at: String,
        updated_at: String
      }
      expect(response.body).to match_json_expression pattern
    end
  end
end
