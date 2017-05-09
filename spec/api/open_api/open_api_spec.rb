require 'rails_helper'

RSpec.describe "Open API" do

  let!(:user) { create(:user)}
  let(:campaign) { create(:campaign)}

  before :each do
    Grape::Endpoint.before_each do |endpoint|
      allow(endpoint).to receive(:current_user).and_return(user)
    end
  end

  describe 'Invites, when client has assigned campaign' do

    before { user.campaigns << campaign }

    it 'returns campagin data' do
      get "/open_api/v1/campaigns/#{campaign.id}/invites"
      expect(JSON.parse(response.body)['success']).to eq true
      expect(response.status).to eq 200
    end
  end

  describe 'Invites, when client revoked campaign' do

    let(:revoked_campaign) { create(:campaign, status:'revoked')}
    before { user.campaigns << revoked_campaign }

    it 'returns message "campaign has been revoked"' do
      get "/open_api/v1/campaigns/#{campaign.id}/invites"
      expect(JSON.parse(response.body)['error']).to eq '客户已撤销活动'
      expect(response.status).to eq 400
    end
  end
end
