FactoryGirl.define do
  factory :kol do
    sequence :email do |n|
      "kol#{n}@email.com"
    end
    # email "kol@email.com"
    # mobile_number "15300731907"
    sequence :mobile_number do |n|
      "1530073190#{n}"
    end
    sequence :name do |n|
      "I'm kol #{n}"
    end
    avatar "www.baidu.com"
    influence_score '701'
    city '上海'
    # name "I'm kol"
    password "12345678"
  end
end
