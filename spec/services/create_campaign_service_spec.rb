require 'rails_helper'

RSpec.describe CreateCampaignService, :type => :service do

  let(:user) { FactoryGirl.create :user }
  let(:campaign_params) do
    {:name => 'Campaign', :description => 'desc', :url => 'http://robin8.net', :budget => 2, :per_budget_type => 'click', :per_action_budget => 0.1, :start_time => Time.now, :deadline => Time.now.tomorrow, :message => 'Message'}
  end

  context 'when perform success' do
    it 'returns true' do
      service = CreateCampaignService.new user, campaign_params

      expect(service.perform).to be_truthy
    end

    it 'creates new campaign' do
      service = CreateCampaignService.new user, campaign_params

      expect{ service.perform }.to change(Campaign, :count).by(1)
    end

    context 'when type is pay_by_click' do
      it 'create pay_by_click campaign' do
        campaign_params[:per_budget_type] = 'click'
        service = CreateCampaignService.new user, campaign_params

        expect{ service.perform }.to change(Campaign, :count).by(1)
        expect(service.campaign.per_budget_type).to eq 'click'
      end
    end

    context 'when type is pay_by_post' do
      it 'create pay_by_post campaign' do
        campaign_params[:per_budget_type] = 'post'
        service = CreateCampaignService.new user, campaign_params

        expect{ service.perform }.to change(Campaign, :count).by(1)
        expect(service.campaign.per_budget_type).to eq 'post'
      end
    end

    context 'when type is pay_by_action' do
      it 'create pay_by_action campaign' do
        campaign_params.merge!({:per_budget_type => 'cpa', :action_url_list => ['http://robin8.com']})
        service = CreateCampaignService.new user, campaign_params

        expect{ service.perform }.to change(Campaign, :count).by(1)
        expect(service.campaign.per_budget_type).to eq 'cpa'
      end
    end
  end

  context 'when perform failure' do
    context 'when invalid user' do
      it 'returns invaild params or user error' do
        invalid_user = User.new
        service = CreateCampaignService.new invalid_user, campaign_params

        expect(service.perform).to be_falsy
        expect(service.errors).to be_include 'Invaild params or user!'
      end
    end

    context 'when invalid campaign_params' do
      it 'returns invalid params or user error' do
        service = CreateCampaignService.new user

        expect(service.perform).to be_falsy
        expect(service.errors).to be_include 'Invaild params or user!'
      end
    end

    context 'when nout enough amount' do
      it 'returns not enouth amount error' do
        poor_user = FactoryGirl.create :poor_user
        service = CreateCampaignService.new poor_user, campaign_params

        expect(service.perform).to be_falsy
        expect(service.errors).to be_include 'Not enough amount!'
      end
    end

    context 'when cpa but no action urls' do
      it 'return no availiable action urls error' do
        campaign_params[:per_budget_type] = 'cpa'
        service = CreateCampaignService.new user, campaign_params

        expect(service.perform).to be_falsy
        expect(service.errors).to be_include 'No availiable action urls!'
      end
    end

    context 'when campaign name absent' do
      it 'return error from activerecord validation' do
        campaign_params.delete :name
        service = CreateCampaignService.new user, campaign_params

        expect(service.perform).to be_falsy
        expect(service.first_error_message).to eq "Name can't be blank"
      end
    end

    context 'when cpa campaign but action urls save failure' do
      it 'rollback' do
        # todo: this case to test action_record will exec rollback, but blow code can't prove it rollback.
        campaign_params.merge!({:per_budget_type => 'cpa', :action_url_list => ['error.url']})
        service = CreateCampaignService.new user, campaign_params

        expect { service.perform }.to change(Campaign, :count).by(0)
      end
    end
  end
end
