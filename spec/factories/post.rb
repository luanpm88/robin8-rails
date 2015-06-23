FactoryGirl.define do
  factory :post do
    text                { FFaker::Lorem.paragraphs }
    scheduled_date      { FFaker::Time.date }
  end
end
