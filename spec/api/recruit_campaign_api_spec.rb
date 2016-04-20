require 'rails_helper'

RSpec.describe "recruit campaign api" do
  before :each do
    @rich_user = FactoryGirl.create :rich_user
    @recruit_campaign = FactoryGirl.create(:recruit_campaign, user: @rich_user)
    login_as(@rich_user, :scope => :user)
  end

  describe "POST /brand_api/v1/recruit_campaigns" do
    let(:recruit_campaign_params) do
      {
        name: 'campaign',
        description: 'Campaign Desc',
        task_description: 'Campaign task Desc',
        url: 'http://robin8.net',
        img_url: 'http://baidu.com',
        region: 'shanghai',
        influence_score: '701',
        recruit_start_time: Time.now,
        recruit_end_time: Time.now + 3.days,
        start_time: Time.now + 4.days,
        deadline: Time.now + 6.days,
        budget: 10,
        per_action_budget: 1,
        per_budget_type: 'recruit'
      }
    end

    it "return 201 and present created recruit campaign" do
      post '/brand_api/v1/recruit_campaigns', recruit_campaign_params

      pattern = {
        id: Integer,
        name: "campaign",
        description: "Campaign Desc",
        short_description: wildcard_matcher,
        task_description: "Campaign task Desc",
        img_url: "http://baidu.com",
        status: "unexecute",
        user: Hash,
        message: wildcard_matcher,
        url: "http://robin8.net",
        budget: 10,
        per_budget_type: "recruit",
        per_action_budget: 1.0,
        recruit_start_time: wildcard_matcher,
        recruit_end_time: wildcard_matcher,
        deadline: wildcard_matcher,
        start_time: wildcard_matcher,
        avail_click: Fixnum,
        post_count: Fixnum,
        join_count: Fixnum,
        total_click: Fixnum,
        fee_info: wildcard_matcher,
        share_time: wildcard_matcher,
        take_budget: Float,
        remain_budget: Float,
        age: wildcard_matcher,
        province: wildcard_matcher,
        city: wildcard_matcher,
        gender: wildcard_matcher,
        region: "shanghai",
        influence_score: "701",
        action_url: wildcard_matcher,
        short_url: wildcard_matcher,
        action_url_identifier: wildcard_matcher,
        created_at: wildcard_matcher,
        updated_at: wildcard_matcher
      }

      expect(response.status).to eq 201
      expect(response.body).to match_json_expression pattern

    end

    it "create campaign succeed" do
      expect { post '/brand_api/v1/recruit_campaigns', recruit_campaign_params }.to change(Campaign, :count).by(1)
    end

    it "return 400 error if params validation failed" do
      recruit_campaign_params.delete :task_description
      post '/brand_api/v1/recruit_campaigns', recruit_campaign_params

      expect(response.status).to eq 400
    end

    it 'return unprocessable when error' do
      current_user = @rich_user
      current_user.update_attributes(amount: 0)
      post '/brand_api/v1/recruit_campaigns', recruit_campaign_params

      expect(response.status).to eq 422

      pattern = {
        error: 'Unprocessable!',
        detail: '账号余额不足, 请充值!'
      }

      expect(response.body).to match_json_expression pattern
    end
  end

  describe "GET /brand_api/v1/recruit_campaigns/:id" do
    it 'return 200' do
      get "/brand_api/v1/recruit_campaigns/#{@recruit_campaign.id}"
      expect(response.status).to eq 200
    end

    it 'return campaign' do
      get "/brand_api/v1/recruit_campaigns/#{@recruit_campaign.id}"

      pattern = {
        id: Integer,
        name: wildcard_matcher,
        description: "Campaign Desc",
        short_description: wildcard_matcher,
        task_description: "Campaign task Desc",
        img_url: "http://baidu.com",
        status: "unexecute",
        user: Hash,
        message: wildcard_matcher,
        url: "http://robin8.net",
        budget: 10,
        per_budget_type: "recruit",
        per_action_budget: 1.0,
        recruit_start_time: wildcard_matcher,
        recruit_end_time: wildcard_matcher,
        deadline: wildcard_matcher,
        start_time: wildcard_matcher,
        avail_click: Fixnum,
        post_count: Fixnum,
        join_count: Fixnum,
        total_click: Fixnum,
        fee_info: wildcard_matcher,
        share_time: wildcard_matcher,
        take_budget: Float,
        remain_budget: Float,
        age: wildcard_matcher,
        province: wildcard_matcher,
        city: wildcard_matcher,
        gender: wildcard_matcher,
        region: "shanghai",
        influence_score: "701",
        action_url: wildcard_matcher,
        short_url: wildcard_matcher,
        action_url_identifier: wildcard_matcher,
        created_at: wildcard_matcher,
        updated_at: wildcard_matcher
      }
      expect(response.body).to match_json_expression pattern
    end
  end

  describe "PUT /brand_api/v1/recruit_campaigns/:id" do
    before :each do
      @update_campaign_params = {
        name: 'new campaign',
        description: 'new Campaign Desc',
        task_description: 'new Campaign task Desc',
        url: 'http://robin8.net',
        img_url: 'http://baidu.com',
        region: 'new region shanghai',
        influence_score: 'new score 701',
        recruit_start_time: Time.now,
        recruit_end_time: Time.now + 3.days,
        start_time: Time.now + 4.days,
        deadline: Time.now + 6.days,
        budget: 10,
        per_action_budget: 1,
        per_budget_type: 'recruit'
      }
    end

    it 'return 200 if update recruit campaign successfully' do
      put "/brand_api/v1/recruit_campaigns/#{@recruit_campaign.id}", @update_campaign_params

      expect(response.status).to eq 200
    end

    it 'campaign fields has changed if update recruit campaign successfully' do
      old_name = @recruit_campaign.name
      old_region = @recruit_campaign.campaign_targets.where(target_type: :region).first.target_content
      old_influence_score = @recruit_campaign.campaign_targets.where(target_type: :influence_score).first.target_content

      put "/brand_api/v1/recruit_campaigns/#{@recruit_campaign.id}", @update_campaign_params

      expect(@recruit_campaign.reload.name).not_to eq old_name
      expect(@recruit_campaign.campaign_targets.where(target_type: :region).first.target_content).not_to eq old_region
      expect(@recruit_campaign.campaign_targets.where(target_type: :influence_score).first.target_content).not_to eq old_influence_score
    end

    it 'return errors when no permission' do
      campaign = FactoryGirl.create :recruit_campaign

      put "/brand_api/v1/recruit_campaigns/#{campaign.id}", @update_campaign_params

      pattern = {
        error: 'Unprocessable!',
        detail: 'No permission!'
      }
      expect(response.status).to eq 422
      expect(response.body).to match_json_expression pattern
    end


  end

end
