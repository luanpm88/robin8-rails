FactoryGirl.define do
  factory :kol do
    sequence(:email) { |n| "kol#{n}@robin8.com" }
    password 'password'
    sequence(:first_name) { |n| "kol#{n}" }
    last_name 'John'
    sequence(:mobile_number) { |n| 18888888888 }
  end

end
