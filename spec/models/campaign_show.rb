require 'rails_helper'

RSpec.describe CampaignShow, :type => :model do
  let(:brand_1) {FactoryGirl.create(:user, :email => "brand_1@gmail.com")}
  let(:kol_1) {FactoryGirl.create(:kol, :email => "kol_1@gmail.com")}

  describe "测试 cpa campaign 点击逻辑" do
    context "当 用户 访问第一步 链接" do
      it "将第一步 访问视为无效点击" do
        
        campaign = create_campaign brand_1, :per_budget_type => :cpa, :budget => 2, per_action_budget: 1

        visit_campaign_for_step_one campaign do
          expect(CampaignShow.last.status).to eq '0'
        end
      end
    end

    context "当 用户 访问第一步 链接 后" do
      it "将第二步的 第一次 访问  视为有效点击, 第二次 视为 无效点击" do
        campaign = create_campaign brand_1, :per_budget_type => :cpa, :budget => 2, per_action_budget: 1
        visit_campaign_for_step_one campaign do
          expect(CampaignShow.last.status).to eq '0'
        end

        visit_campaign_for_step_two campaign do
          expect(CampaignShow.last.status).to eq '1'
        end

        visit_campaign_for_step_two campaign do
          expect(CampaignShow.last.status).to eq '0'
        end
      end
    end

    context "当 用户 没有访问第一步" do
      it "将第二步的访问 视为 无效点击" do
        campaign = create_campaign brand_1, :per_budget_type => :cpa, :budget => 2, per_action_budget: 1
        visit_campaign_for_step_two campaign, 0
      end
    end

    context "当预算 花完后" do
      it "kol 收入 增加" do
        campaign = create_campaign brand_1, :per_budget_type => :cpa, :budget => 1, per_action_budget: 1
        
        visit_campaign_for_step_one campaign do
          expect(CampaignShow.last.status).to eq '0'
        end
        
        campaign_invite = CampaignInvite.find_by :campaign_id => campaign.id, :kol_id => kol_1.id
        campaign_invite.update_columns(:screenshot => "screenshot", :img_status => "passed")

        visit_campaign_for_step_two campaign do
          expect(CampaignShow.last.status).to eq '1'
        end

        kol_old_amount = kol_1.reload.amount.to_i
        brand_old_amount = brand_1.reload.amount.to_i
        brand_old_frozen_amount = brand_1.frozen_amount.to_i

        campaign.settle_accounts_for_kol

        kol_1.reload
        brand_1.reload

        expect(kol_old_amount)
      end
    end
  end



  private

  def visit_campaign_for_step_one campaign
    clear_redis_cache campaign, "vistor_01"

    brand_1.reload
    
    campaign_invite = CampaignInvite.find_by :kol_id => kol_1.id, :campaign_id => campaign.id
    approve_campaign campaign_invite
    
    expect{
      CampaignShowWorker.new.perform(campaign_invite.uuid, "vistor_01", '127.0.0.1', 'user agent', "referer", {})
    }.to change{
      CampaignShow.count
    }.by(1)

    yield if block_given?
  end

  def visit_campaign_for_step_two campaign, incr_count=1
    brand_1.reload
    
    campaign_action_url = campaign.campaign_action_urls.first
    expect{
      CampaignShowWorker.new.perform(campaign_action_url.uuid, "vistor_01", '127.0.0.1', 'user agent', "referer", {:step => 2})
    }.to change{
      CampaignShow.count
    }.by(incr_count)

    yield if block_given?
  end

  def create_campaign user, campaign_params={}
    kol_1.save
    campaign = FactoryGirl.create(:campaign, campaign_params.merge(:user_id => user.id, :status => "unexecute"))

    campaign_action_url = FactoryGirl.create(:campaign_action_url, :campaign_id => campaign.id, :action_url => "http://baidu.com")
    
    campaign.status = "agreed"
    campaign.save

    campaign.go_start

    campaign.reload
  end

  def approve_campaign campaign_invite
    campaign_invite.update_attributes({status: 'approved', approved_at: Time.now})
    campaign_invite.generate_uuid_and_share_url
    campaign_invite.reload
  end

  def clear_redis_cache campaign, visitor_cookies
    Rails.cache.delete visitor_cookies.to_s + campaign.id.to_s
    campaign.redis_avail_click.clear
    campaign.redis_total_click.clear
    CampaignInvite.all.each do |invite|
      invite.redis_total_click.clear
      invite.redis_avail_click.clear
    end
  end
end
