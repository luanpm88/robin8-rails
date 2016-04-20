FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "staff_#{n}@robin8.com"
    end
    sequence :name do |n|
      "staff_#{n}"
    end
    sequence :mobile_number do |n| 
      "1335428962#{n}"
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
