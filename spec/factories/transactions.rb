FactoryGirl.define do
  factory :transaction do

    item_type 'alipay_order'
    subject 'alipay_recharge'
    credits '500'
    avail_amount '1000'
    trade_no Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
    association :account, factory: :user

  end

end
