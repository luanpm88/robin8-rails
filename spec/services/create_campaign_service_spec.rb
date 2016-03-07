require 'rails_helper'

RSpec.describe CreateCampaignService, :type => :service do

  let(:campaign_params) do
    {:name => 'Campaign', :description => 'desc', :url => 'http://robin8.net', :budget => 2, :per_budget_type => 'click', :per_action_budget => 0.1, :start_time => Time.now, :deadline => Time.now.tomorrow, :message => 'Message'}
  end

  it 'create new pay_by_click(default) type campaign' do
    rich_user = FactoryGirl.create :rich_user
    service = CreateCampaignService.new rich_user, campaign_params

    expect { service.perform }.to change(Campaign, :count).by(1)
    expect(service.campaign.per_budget_type).to eq 'click'
  end

  it 'create new pay_by_post type campaign' do
    rich_user = FactoryGirl.create :rich_user
    campaign_params[:per_budget_type] = 'post'
    service = CreateCampaignService.new rich_user, campaign_params

    expect { service.perform }.to change(Campaign, :count).by(1)
    expect(service.campaign.per_budget_type).to eq 'post'
  end

  it 'create new CPA type campaign' do
    rich_user = FactoryGirl.create :rich_user
    campaign_params.merge!({:per_budget_type => 'cpa', :action_url_list => ['http://robin8.com', 'http://robin8.net']})
    service = CreateCampaignService.new rich_user, campaign_params

    expect { service.perform }.to change(Campaign, :count).by(1)
    expect(service.campaign.per_budget_type).to eq 'cpa'
  end

  it 'returns true for create campaign success' do
    rich_user = FactoryGirl.create :rich_user
    service = CreateCampaignService.new rich_user, campaign_params

    expect(service.perform).to be_truthy
  end

  it 'returns false and error for invaild user' do
    user = User.new
    service = CreateCampaignService.new user, campaign_params

    expect(service.perform).to be_falsy
    expect(service.errors).to be_include 'Invaild params or user!'
  end

  it 'returns false and error for empty campaigns params' do
    user = FactoryGirl.create :user
    service = CreateCampaignService.new user

    expect(service.perform).to be_falsy
    expect(service.errors).to be_include 'Invaild params or user!'
  end

  it 'returns false and error for not enough amount' do
    poor_user = FactoryGirl.create :poor_user

    service = CreateCampaignService.new poor_user, campaign_params
    
    expect(service.perform).to be_falsy
    expect(service.errors).to be_include 'Not enough amount!'
  end

  it 'returns false and error for cpa type but no action urls' do
    user = FactoryGirl.create :user

    campaign_params[:per_budget_type] = 'cpa'
    service = CreateCampaignService.new user, campaign_params

    expect(service.perform).to be_falsy
    expect(service.errors).to be_include 'No availiable action urls!'
  end

  it 'returns errors for campaign name absent' do
    campaign_params.delete :name
    user = FactoryGirl.create :user
    service = CreateCampaignService.new user, campaign_params

    expect(service.perform).to be_falsy
    expect(service.first_error_message).to be_include "Name can't be blank"
  end

  it 'returns false for CPA type campaign action urls save failure' do
    campaign_params.merge!({:per_budget_type => 'cpa', :action_url_list => [] })
    user = FactoryGirl.create :user
    service = CreateCampaignService.new user, campaign_params

    result = nil
    expect { result = service.perform }.to change(Campaign, :count).by(0)
    expect(result).to be_falsy
  end

  it 'rollback for CPA type campaign action urls format error' do
    campaign_params.merge!({:per_budget_type => 'cpa', :action_url_list => ['url.error.msg'] })
    user = FactoryGirl.create :user
    service = CreateCampaignService.new user, campaign_params

    expect { service.perform }.to change(Campaign, :count).by(0)
  end
end
