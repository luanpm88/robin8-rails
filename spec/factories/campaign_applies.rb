FactoryGirl.define do
  factory :campaign_apply do
    campaign { FactoryGirl.create(:campaign) }
    kol { FactoryGirl.create(:kol) }
    status 'platform_passed'
    agree_reason 'test'
  end
end
