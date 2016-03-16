require 'rails_helper'

RSpec.describe Brand::V1::UserAPI do
  # For we need login to auth, use feature spec not request spec
  describe 'GET /brand_api/v1/user/campaigns', :type => :feature do
    before :each do
      @rich_user = FactoryGirl.create(:rich_user)
      FactoryGirl.create(:campaign, user: @rich_user)

      login_as(@rich_user, :scope => :user)
    end

    it 'returns 200' do
      get '/brand_api/v1/user/campaigns'

      expect(response.status).to eq 200
    end

    it 'returns 401 for not yet logged' do
      logout :user
      get '/brand_api/v1/user/campaigns'

      expect(response.status).to eq 401
    end

   # todo: it should move to shared example
    it 'supports paginate' do
      get '/brand_api/v1/user/campaigns'

      expect(response.header).to be_include('X-Offset')
      expect(response.header).to be_include('X-Page')
      expect(response.header).to be_include('X-Per-Page')
      expect(response.header).to be_include('X-Next-Page')
      expect(response.header).to be_include('X-Prev-Page')
      expect(response.header).to be_include('X-Total')
      expect(response.header).to be_include('X-Total-Pages')
    end

    it 'returns campaigns belongs to current_user' do
      get '/brand_api/v1/user/campaigns'

      pattern = {
        items: [{
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
        }],
        paginate: Hash
      }
      expect(response.body).to match_json_expression pattern
    end
  end
end
