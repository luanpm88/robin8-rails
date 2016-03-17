require 'rails_helper'

RSpec.describe UpdateCampaignService, :type => :service do
  
  let(:user) { FactoryGirl.create :user }
  let(:campaign) { FactoryGirl.create :cpa_campaign, user: user }
  let(:update_campaign_params) do
    { :name => 'new_campaign', :description => 'desc', :url => 'http://robin8.net', :budget => 2, :per_budget_type => 'cpa', :per_action_budget => 0.1, :start_time => Time.now, :deadline => Time.now.tomorrow, :message => 'Message', :action_url_list => ['http://robin8.com'] }
  end

  context 'when perform success' do
    it 'returns true' do
      service = UpdateCampaignService.new user, campaign.id, update_campaign_params

      expect(service.perform).to be_truthy
    end

    it 'updated campaign' do
      old_campaign_name = campaign.name
      service = UpdateCampaignService.new user, campaign.id, update_campaign_params

      expect { service.perform }.to change{ campaign.reload.name }.from(old_campaign_name).to('new_campaign')
    end
  end

  context 'when perform failed' do
    context 'when user have no permission' do
      it 'returns no permission' do
        new_user = FactoryGirl.create :user
        service = UpdateCampaignService.new new_user, campaign.id, update_campaign_params

        expect(service.perform).to be_falsy
        expect(service.first_error_message).to eq 'No permission!'
      end
    end

    context 'when nil user' do
      it 'returns invalid params or user/campaign' do
        service = UpdateCampaignService.new nil, campaign.id, update_campaign_params

        expect(service.perform).to be_falsy
        expect(service.first_error_message).to eq 'Invalid params or user/campaign!'
      end
    end

    context 'when cpa but no action urls' do
      it 'returns no availiable action urls' do
        update_campaign_params.delete :action_url_list
        service = UpdateCampaignService.new user, campaign.id, update_campaign_params

        expect(service.perform).to be_falsy
        expect(service.first_error_message).to eq 'No availiable action urls!'
      end
    end
  end
end
