require 'rails_helper'

describe Release do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }

  describe "validations of new release" do
    before(:each) do
      allow(user).to receive(:can_create_release).and_return(true)
    end

    it "create release with valid title" do
      release = FactoryGirl.build(:release, title: 'Test title')
      release.user = user
      expect(release).to be_valid
    end

    it "require valid title" do
      release = FactoryGirl.build(:release, title: nil)
      release.user = user
      expect(release).not_to be_valid
    end

    it "require valid user id" do
      release = FactoryGirl.build(:release, title: nil)
      release.user = nil
      expect(release).not_to be_valid
    end

    it "require user can create release" do
      allow(user).to receive(:can_create_release).and_return(false)
      release = FactoryGirl.build(:release, title: 'Test title')
      release.user = user
      expect(release).not_to be_valid
    end
  end
end
