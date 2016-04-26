FactoryGirl.define do
  factory :recruit_campaign, :class => 'Campaign' do
    sequence :name do |n|
      "Campaign No.#{n}"
    end

    user { FactoryGirl.create(:rich_user) }

    description 'Campaign Desc'
    task_description 'Campaign task Desc'
    address '江宁路'
    img_url 'http://baidu.com'
    recruit_start_time Time.now
    recruit_end_time Time.now + 3.days
    start_time Time.now + 4.days
    deadline Time.now + 6.days
    budget 10
    per_budget_type 'recruit'
    per_action_budget 1
    status 'unexecute'

    after(:create) do |campaign, evaluator|
      create(:campaign_target, campaign: campaign, target_type: "region", target_content: "shanghai")
      create(:campaign_target, campaign: campaign, target_type: "influence_score", target_content: "701")
    end

  end
end
