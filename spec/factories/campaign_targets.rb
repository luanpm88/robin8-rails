FactoryGirl.define do
  factory :campaign_target do
    target_type "MyString"
    target_content "MyString"
    campaign { FactoryGirl.create :campaign }
  end

end
