require 'rails_helper'

describe UserFeature do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }
  before do
    allow_any_instance_of(UserProduct).to receive(:create_payment)
    allow_any_instance_of(NewsRoom).to receive(:create_campaign)
    allow_any_instance_of(NewsRoom).to receive(:set_campaign_name)
  end

  describe "user_feature - release" do
    let!(:product) { create(:product, id: 1, slug: "premium-annual", is_active: true, price: 4980.00,
               interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 2257487,is_package: true) }
    let!(:user_product) { create(:user_product, product_id: 1, user: user, status: "A", next_charge_date: Date.today + 30, bluesnap_shopper_id: "19986241") }
    
    let!(:feature) { create(:feature, slug: 'press_release', id: 1, name: 'Release') }
    let!(:user_feature) { create(:user_feature, feature_id: 1, product_id: 1, user_id: user.id, available_count: 1) }

    it "creating release" do
      release = build(:release, title: 'Test title', user: user)
      expect(release).to be_valid
    end

    it "can_create_release should be true" do
      expect(user.can_create_release).to eq true
    end

    it "can_create_release should be false" do
      release = create(:release, title: 'Test title', user: user)
      expect(user.can_create_release).to eq false
    end

    it "release_available_count should be 0" do
      release = create(:release, title: 'Test title', user: user)
      expect(user.release_available_count).to eq 0
    end

    it "release_available_count should be 1" do
      expect(user.release_available_count).to eq 1
    end

    it "release_available_count should be correct" do
      release = create(:release, title: 'Test title', user: user)
      expect(user.release_available_count).to eq 0
      release.destroy
      expect(user.release_available_count).to eq 1
    end

    it "release_count should be correct" do
      release = create(:release, title: 'Test title', user: user)
      expect(user.release_count).to eq 1
    end
  end

  describe "user_feature - stream" do
    let!(:product) { create(:product, id: 1, slug: "premium-annual", is_active: true, price: 4980.00,
               interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 2257487,is_package: true) }
    let!(:user_product) { create(:user_product, product_id: 1, user: user, status: "A", next_charge_date: Date.today + 30, bluesnap_shopper_id: "19986241") }
    
    let!(:feature) { create(:feature, slug: 'media_monitoring', id: 1, name: 'Stream') }
    let!(:user_feature) { create(:user_feature, feature_id: 1, product_id: 1, user_id: user.id, available_count: 1) }

    it "creating stream" do
      stream = FactoryGirl.create(:stream, sort_column: 'published_at', user: user)
      expect(stream).to be_valid
    end

    it "can_create_stream should be true" do
      expect(user.can_create_stream).to eq true
    end

    it "can_create_stream should be false" do
      stream = FactoryGirl.create(:stream, sort_column: 'published_at', user: user)
      expect(user.can_create_stream).to eq false
    end

    it "stream_available_count should be 0" do
      stream = FactoryGirl.create(:stream, sort_column: 'published_at', user: user)
      expect(user.stream_available_count).to eq 0
    end

    it "stream_available_count should be 1" do
      expect(user.stream_available_count).to eq 1
    end

    it "stream_available_count should be correct" do
      stream = FactoryGirl.create(:stream, sort_column: 'published_at', user: user)
      expect(user.stream_available_count).to eq 0
      stream.destroy
      expect(user.stream_available_count).to eq 1
    end

    it "stream_count should be correct" do
      stream = FactoryGirl.create(:stream, sort_column: 'published_at', user: user)
      expect(user.stream_count).to eq 1
    end
  end

  describe "user_feature - newsroom" do
    let!(:product) { create(:product, id: 1, slug: "premium-annual", is_active: true, price: 4980.00,
               interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 2257487,is_package: true) }
    let!(:user_product) { create(:user_product, product_id: 1, user: user, status: "A", next_charge_date: Date.today + 30, bluesnap_shopper_id: "19986241") }
    
    let!(:feature) { create(:feature, slug: 'newsroom', id: 1, name: 'Newsroom') }
    let!(:user_feature) { create(:user_feature, feature_id: 1, product_id: 1, user_id: user.id, available_count: 1) }

    it "creating stream" do
      news_room = create(:news_room, company_name: 'Test title', user: user)
      expect(news_room).to be_valid
    end

    it "can_create_newsroom should be true" do
      expect(user.can_create_newsroom).to eq true
    end

    it "can_create_newsroom should be false" do
      news_room = create(:news_room, company_name: 'Test title', user: user)
      expect(user.can_create_newsroom).to eq false
    end

    it "newsroom_available_count should be 0" do
      news_room = create(:news_room, company_name: 'Test title', user: user)
      expect(user.newsroom_available_count).to eq 0
    end

    it "newsroom_available_count should be 1" do
      expect(user.newsroom_available_count).to eq 1
    end

    it "newsroom_available_count should be correct" do
      news_room = create(:news_room, company_name: 'Test title', user: user)
      expect(user.newsroom_available_count).to eq 0
      news_room.destroy
      expect(user.newsroom_available_count).to eq 1
    end

    it "newsroom_count should be correct" do
      news_room = create(:news_room, company_name: 'Test title', user: user)
      expect(user.newsroom_count).to eq 1
    end
  end

  describe "user_feature - seat" do
    let!(:product) { create(:product, id: 1, slug: "premium-annual", is_active: true, price: 4980.00,
               interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 2257487,is_package: true) }
    let!(:user_product) { create(:user_product, product_id: 1, user: user, status: "A", next_charge_date: Date.today + 30, bluesnap_shopper_id: "19986241") }
    
    let!(:feature) { create(:feature, slug: 'seat', id: 1, name: 'Seat') }
    let!(:user_feature) { create(:user_feature, feature_id: 1, product_id: 1, user_id: user.id, available_count: 1) }

    it "can_create_seat should be true" do
      expect(user.can_create_seat).to eq true
    end

    it "can_create_seat should be false" do
      invited_user = create(:user, email: 'invited_test@test.com', id: 2, invited_by: user, is_primary: false) 
      expect(user.can_create_seat).to eq false
    end

    it "seat_available_count should be 0" do
      invited_user = create(:user, email: 'invited_test@test.com', id: 2, invited_by: user, is_primary: false) 
      expect(user.seat_available_count).to eq 0
    end

    it "seat_available_count should be 1" do
      expect(user.seat_available_count).to eq 1
    end

    it "seat_available_count should be correct" do
      invited_user = create(:user, email: 'invited_test@test.com', id: 2, invited_by: user, is_primary: false) 
      expect(user.seat_available_count).to eq 0
      invited_user.destroy
      expect(user.seat_available_count).to eq 1
    end

    it "seat_count should be correct" do
      invited_user = create(:user, email: 'invited_test@test.com', id: 2, invited_by: user, is_primary: false) 
      expect(user.seat_count).to eq 2
    end
  end
end
