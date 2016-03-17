FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "staff_#{n}@robin8.com"
    end
    password 'password'
    password_confirmation 'password'

    factory :rich_user do
      amount 1000
    end

    factory :poor_user do
      amount 0
    end
  end
end
