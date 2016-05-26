require 'rails_helper'

RSpec.describe Brand::V1::TransactionsAPI do
  describe 'GET /brand_api/v1/transactions', :type => :feature do
    before :each do
      @user = FactoryGirl.create :user
      @transaction = FactoryGirl.create(:transaction, account: @user)
      login_as(@user, :scope => :user)
    end

    it 'returns 200' do
      get '/brand_api/v1/transactions'
      expect(response.status).to eq 200
    end
  end
end
