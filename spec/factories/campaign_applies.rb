FactoryGirl.define do
  factory :campaign_apply do
    campaign_invite { FactoryGirl.create(:campaign_invite) }
    campaign { FactoryGirl.create(:recruit_campaign) }
    kol { FactoryGirl.create(:kol) }
    status 'platform_passed'
    agree_reason 'test'
  end
end
