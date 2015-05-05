FactoryGirl.define do
  factory :release do
    title               { FFaker::Product.product_name }
    text                { FFaker::Lorem.paragraphs }
    news_room_id        1
    user_id             1
    slug                { FFaker::Internet.slug }
  end
end
