FactoryGirl.define do
  factory :news_room do
    company_name        { FFaker::Product.product_name }
    user_id             1
    subdomain_name      { FFaker::Product.product_name }
  end
end
