FactoryGirl.define do
  factory :stream do
    sort_column              'published_at'
    position        1
    user_id             1
    # slug                { FFaker::Internet.slug }
  end
end
