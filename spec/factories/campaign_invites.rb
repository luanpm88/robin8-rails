FactoryGirl.define do
  factory :campaign_invite do
    campaign { FactoryGirl.create(:recruit_campaign) }
    kol { FactoryGirl.create(:kol) }
    total_click 10
    avail_click 5
    status 'approved'
    img_status 'pending'
    screenshot 'www.baidu.com'
  end
end
