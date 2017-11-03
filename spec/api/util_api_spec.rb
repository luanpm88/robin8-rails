=begin
require 'rails_helper'

RSpec.describe Brand::V1::UtilAPI do
  describe 'GET /brand_api/v1/util/qiniu_token', :type => :feature do
    before :each do
      @user = FactoryGirl.create :user

      login_as(@user, :scope => :user)
    end

    it 'returns 200' do
      get '/brand_api/v1/util/qiniu_token'

      expect(response.status).to eq 200
    end

    it 'returns token' do
      get '/brand_api/v1/util/qiniu_token'

      pattern = { uptoken: String }

      expect(response.body).to match_json_expression pattern
    end

    it 'authentication' do
      logout :user
      get '/brand_api/v1/util/qiniu_token'

      expect(response.status).to eq 401
    end
  end
end
=end
