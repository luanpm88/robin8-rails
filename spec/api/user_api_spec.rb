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
          # TODO: age, province, city, gender should merge in one object, not flatten!
          age: String,
          province: String,
          city: String,
          gender: String,
          action_url: String,
          short_url: String,
          action_url_identifier: String,
          created_at: String,
          updated_at: String
        }],
        paginate: Hash
      }
      expect(response.body).to match_json_expression pattern
    end
  end

  describe 'GET /brand_api/v1/user', :type => :feature do
    before :each do
      @user = FactoryGirl.create(:user)

      login_as(@user, :scope => :user)
    end

    it 'returns 200' do
      get '/brand_api/v1/user'

      expect(response.status).to eq 200
    end

    it 'returns current_user' do
      get '/brand_api/v1/user'

      # use `wildcard_matcher to only make use key exists`
      pattern = {
        id: wildcard_matcher,
        name: wildcard_matcher,
        real_name: wildcard_matcher,
        description: wildcard_matcher,
        keywords: wildcard_matcher,
        url: wildcard_matcher,
        email: wildcard_matcher,
        avatar_url: wildcard_matcher,
        mobile_number: wildcard_matcher,
        amount: wildcard_matcher,
        frozen_amount: wildcard_matcher,
        avail_amount: wildcard_matcher
      }
      expect(response.body).to match_json_expression pattern
    end
  end

  describe 'PUT /brand_api/v1/user', :type => :feature do
    before :each do
      @user = FactoryGirl.create :user

      login_as(@user, :scope => :user)
    end
    let(:update_user_params) do
      {:name => 'new_name', :real_name => 'new_real_name', :description => 'new_desc', :keywords => 'new_keywords', :url => 'http://robin8.net', :avatar_url => ''}
    end

    it 'returns 200' do
      put '/brand_api/v1/user', update_user_params

      expect(response.status).to eq 200
    end

    it 'returns updated user' do
      put '/brand_api/v1/user', update_user_params

      pattern = {
        id: wildcard_matcher,
        name: 'new_name',
        real_name: 'new_real_name',
        description: 'new_desc',
        keywords: 'new_keywords',
        url: 'http://robin8.net',
        email: wildcard_matcher,
        avatar_url: wildcard_matcher,
        mobile_number: wildcard_matcher,
        amount: wildcard_matcher,
        frozen_amount: wildcard_matcher,
        avail_amount: wildcard_matcher
      }
      expect(response.body).to match_json_expression pattern
    end
  end

  describe 'PUT /brand_api/v1/user/avatar', :type => :feature do
    before :each do
      @user = FactoryGirl.create :user

      login_as(@user, :scope => :user)
    end
    let(:params) do
      {:avatar_url => 'http://robin8.com'}
    end

    it 'returns 200' do
      put '/brand_api/v1/user/avatar', params

      expect(response.status).to eq 200
    end
  end

  describe 'PUT /brand_api/v1/uesr/password', :type => :feature do
    before :each do
      @user = FactoryGirl.create :user

      login_as(@user, :scope => :user)
    end
    let(:params) do
      { :password => 'password', :new_password => 'new password', :new_password_confirmation => 'new_password' }
    end

    it 'returns 200' do
      put '/brand_api/v1/user/password', params

      expect(response.status).to eq 200
    end

    it 'returns error when password invalid' do
      params.merge!({:password => 'pwd'})
      put '/brand_api/v1/user/password', params

      expect(response.status).to eq 422
      expect(response.body).to be_include 'Invalid password!'
    end
  end
end
