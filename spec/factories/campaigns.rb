FactoryGirl.define do
  factory :campaign do
    sequence :name do |n|
      "Campaign No.#{n}"
    end

    user { FactoryGirl.create(:rich_user) }
    
    start_time Time.now
    deadline Time.now.tomorrow
    description 'Campaign Desc'
    budget 10
    url 'http://robin8.net'
    per_action_budget 1.0
    per_budget_type 'click'
    status 'unexecute'

    transient do
      target_count 3
    end

    after(:create) do |campaign, evaluator|
      type_list = ['age', 'region', 'gender']
      evaluator.target_count.times do |index|
	create(:campaign_target, campaign: campaign, target_type: type_list[index])
      end
    end

    factory :cpa_campaign do
      transient do
        action_urls_count 3
      end

      per_budget_type 'cpa'

      after(:create) do |campaign, evaluator|
        create_list(:campaign_action_url, evaluator.action_urls_count, campaign: campaign)
      end
    end
  end
end
