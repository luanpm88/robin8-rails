require 'rails_helper'

RSpec.describe API::SearchEngine::Kols do
  describe 'GET /api/search_engine/kols/:id/details', :type => :feature do
    # before :each do
    #   @user = FactoryGirl.create :user
    #
    #   login_as(@user, :scope => :user)
    # end

    before do
      Grape::Endpoint.before_each do |endpoint|
        allow(endpoint).to receive(:authenticate_from_engine!).and_return(true)
      end
    end

    it 'returns 200' do
      get '/api/search_engine/kols/12/detail'
      expect(response.status).to eq 200
    end
  end
end

