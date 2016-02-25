require 'rails_helper'

RSpec.describe CampaignShow, :type => :model do
  let(:brand_1) {FactoryGirl.create(:user, :email => "brand_1@gmail.com")}
  let(:kol_1) {FactoryGirl.create(:kol, :email => "kol_1@gmail.com")}

  describe "测试 cpa campaign 点击逻辑" do
    context "当 用户 访问第一步 链接" do
      it "将第一步 访问视为无效点击" do
        campaign = create_campaign brand_1, :per_budget_type => :cpa, :budget => 2, per_action_budget: 1
        brand_1.reload
        

        approve_campaign_by_admin_user campaign, kol_1

        campaign_invite = CampaignInvite.find_by :campaign_id => campaign.id, :kol_id => kol_1.id
        approve_campaign campaign_invite
        CampaignShowWorker.new.perform(campaign_invite.uuid, "vistor_01", '127.0.0.1', 'user agent', "referer", {})

        expect(campaign_invite.last.status).to eq '0'
      end
    end
  end

  private

  def create_campaign user, campaign_params={}
    FactoryGirl.create(:campaign, campaign_params.merge(:user_id => user.id))
  end

  def approve_campaign_by_admin_user campaign, kol
    campaign.update_column(:status, "agreed")
    campaign.send_invites([kol_1.id])
  end

  def approve_campaign campaign_invite
    campaign_invite.update_attributes({status: 'approved', approved_at: Time.now})
    campaign_invite.generate_uuid_and_share_url
    campaign_invite.reload
  end
end
