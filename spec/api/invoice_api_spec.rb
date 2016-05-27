require 'rails_helper'

RSpec.describe Brand::V1::Invoice do
  describe 'GET /brand_api/v1/invoice', :type => :feature do
    before :each do
      @user = FactoryGirl.create :user
      login_as(@user, :scope => :user)
    end

    it 'returns 200' do
      get '/brand_api/v1/invoice'
      expect(response.status).to eq 200
    end
  end
end
