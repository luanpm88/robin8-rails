FactoryGirl.define do
  factory :campaign_target do
    target_type "age"
    target_content "all"
    campaign { FactoryGirl.create :campaign }
  end

end
