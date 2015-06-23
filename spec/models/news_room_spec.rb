require 'rails_helper'

describe NewsRoom do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }

  describe "validations of new news rooms" do
    before(:each) do
      allow(user).to receive(:can_create_newsroom).and_return(true)
    end

    it "create newsroom with valid company_name" do
      news_room = build(:news_room, company_name: 'Test title', user: user)
      expect(news_room).to be_valid
    end

    it "require valid company_name" do
      news_room = build(:news_room, company_name: '', user: user)
      expect(news_room).not_to be_valid
    end

    it "require user can create news_room" do
      allow(user).to receive(:can_create_newsroom).and_return(false)
      news_room = build(:news_room, company_name: 'Test title', user: user)
      expect(news_room).not_to be_valid
    end
  end

  describe "before and after callbacks for user features" do
    let!(:feature) { create(:feature, slug: 'newsroom', id: 1, name: 'Streams - Media Monitoring') }
    let!(:user_feature) { create(:user_feature, feature_id: 1, user_id: user.id, available_count: 3) }

    before(:each) do
      allow_any_instance_of(NewsRoom).to receive(:create_campaign)
      allow_any_instance_of(NewsRoom).to receive(:delete_campaign)
      allow_any_instance_of(NewsRoom).to receive(:set_campaign_name)
      allow(user).to receive(:can_create_newsroom).and_return(true)
    end

    it "should increase and decrease available monitoring user features count" do
      news_room = create(:news_room, company_name: 'Test title', user: user)
      expect(user.user_features.first.available_count).to eq 2
      news_room.destroy
      expect(user.user_features.first.available_count).to eq 3
    end
  end
end
