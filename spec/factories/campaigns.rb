FactoryGirl.define do
  factory :campaign do
    name "campaign name"
    short_description "campaign short description"
    start_time Time.now
    status "unexecute"

    deadline Time.now + 10.minutes
    per_budget_type "cpa"
    per_action_budget 1

    budget 5
  end
end