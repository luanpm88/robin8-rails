FactoryGirl.define do
  factory :campaign_action_url do
    action_url 'http://robin8.net'
    campaign { FactoryGirl.create :campaign }
  end
end
