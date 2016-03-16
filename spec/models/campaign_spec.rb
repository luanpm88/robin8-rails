require 'rails_helper'

RSpec.describe Campaign, :type => :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:budget) }
  it { is_expected.to validate_presence_of(:per_budget_type) }
  it { is_expected.to validate_presence_of(:per_action_budget) }
  it { is_expected.to validate_presence_of(:start_time) }
  it { is_expected.to validate_presence_of(:deadline) }
  it { is_expected.to have_many(:campaign_targets) }

  let(:brand_1) {FactoryGirl.create(:user, :email => "brand_1@gmail.com")}
  describe "测试 创建campaign 相关逻辑" do
    context "当 brand amount 足够时, 创建 campaign" do
      it "brand avail_amount 会减少" do
        old_amount = brand_1.amount
        old_frozen_amount = brand_1.frozen_amount

        budget = 2
        campaign = create_campaign brand_1, :per_budget_type => :cpa, :budget => budget, per_action_budget: 1
        
        brand_1.reload
        
        expect(brand_1.amount).to eq old_amount
        expect(brand_1.frozen_amount).to eq (old_frozen_amount + budget)
      end
    end
  end

  private

  def create_campaign user, campaign_params={}
    FactoryGirl.create(:campaign, campaign_params.merge(:user_id => user.id))
  end
end
