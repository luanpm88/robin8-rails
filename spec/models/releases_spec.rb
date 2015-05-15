require 'rails_helper'

describe Release do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }

  describe "validations of new release" do
    before(:each) do
      allow(user).to receive(:can_create_release).and_return(true)
    end

    it "create release with valid title" do
      release = build(:release, title: 'Test title', user: user)
      expect(release).to be_valid
    end

    it "require valid title" do
      release = build(:release, title: nil, user: user)
      expect(release).not_to be_valid
    end

    it "require user can create release" do
      allow(user).to receive(:can_create_release).and_return(false)
      release = build(:release, title: 'Test title', user: user)
      expect(release).not_to be_valid
    end
  end

  describe "before and after callbacks for user features" do
    let!(:feature) { create(:feature, slug: 'press_release', id: 1, name: 'Streams - Media Monitoring') }
    let!(:user_feature) { create(:user_feature, feature_id: 1, user_id: user.id, available_count: 3) }

    before(:each) do
      allow(user).to receive(:can_create_release).and_return(true)
    end

    it "should increase and decrease available monitoring user features count" do
      release = create(:release, title: 'Test title', user: user)
      expect(user.user_features.first.available_count).to eq 2
      release.destroy
      expect(user.user_features.first.available_count).to eq 3
    end
  end
end
