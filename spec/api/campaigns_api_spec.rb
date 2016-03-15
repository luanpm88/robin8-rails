require 'rails_helper'

RSpec.describe Brand::V1::CampaignsAPI do
  before :each do
    @rich_user = FactoryGirl.create :rich_user
    @campaign = FactoryGirl.create(:campaign, user: @rich_user)

    login_as(@rich_user, :scope => :user)
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

  describe 'POST /brand_api/v1/campaigns', :type => :feature do
    let(:campaign_params) do
      {:name => 'campaign', :description => 'desc', :url => 'http://robin8.com', :budget => 1.0, :per_budget_type => 'click', :per_action_budget => 1.0, :start_time => Time.now, :deadline => Time.now.tomorrow}
    end

    it 'returns 201 and present created campaign' do
      post '/brand_api/v1/campaigns', campaign_params

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

      expect(response.status).to eq 201
      expect(response.body).to match_json_expression pattern
    end

    it 'created campaign' do
      expect { post '/brand_api/v1/campaigns', campaign_params }.to change(Campaign, :count).by(1)
    end

    it 'returns 400 for params validation failed' do
      campaign_params.delete :per_action_budget
      post '/brand_api/v1/campaigns', campaign_params

      expect(response.status).to eq 400
    end

    it 'returns unprocessable when error' do
      current_user = @rich_user
      current_user.update_attributes(amount: 0)
      post '/brand_api/v1/campaigns', campaign_params

      expect(response.status).to eq 422

      pattern = {
        error: 'Unprocessable!',
        detail: 'Not enough amount!'
      }
      expect(response.body).to match_json_expression pattern
    end
  end

  describe 'PUT /brand_api/v1/campaigns/:id' do

    before :each do
      @update_campaign_params = @campaign.attributes.select {|k,v| CreateCampaignService::PERMIT_PARAMS.include? k.to_sym }.merge({:name => 'new name'})
    end

    it 'returns 200' do
      put "/brand_api/v1/campaigns/#{@campaign.id}", @update_campaign_params

      expect(response.status).to eq 200
    end

    it 'changed campaign' do
      expect { put "/brand_api/v1/campaigns/#{@campaign.id}", @update_campaign_params }.to change{ @campaign.reload.name }.from(@campaign.name).to(@update_campaign_params[:name])
    end

    it 'return errors when no permission' do
      campaign = FactoryGirl.create :campaign

      put "/brand_api/v1/campaigns/#{campaign.id}", @update_campaign_params

      expect(response.status).to eq 422
      pattern = {
        error: 'Unprocessable!',
        detail: 'No permission!'
      }
      expect(response.body).to match_json_expression pattern
    end
  end
end
