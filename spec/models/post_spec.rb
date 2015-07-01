require 'rails_helper'

describe Post do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }
  
  before do
    allow_any_instance_of(Post).to receive(:perform_worker)
  end

  describe "validations of new post" do

    it "create post with valid text" do
      post = build(:post, text: 'Test text', user: user)
      expect(post).to be_valid
    end

    it "require valid text" do
      post = build(:post, text: '', user: user)
      expect(post).not_to be_valid
    end

    it "require valid scheduled_date" do
      post = build(:post, scheduled_date: '', user: user)
      expect(post).not_to be_valid
    end
  end

  describe "Posts" do

    it "should have :todays post" do
      create(:post, scheduled_date: DateTime.now + 4.hour)
      expect(Post.todays).not_to be_empty
    end

    it "should have :tomorrows post" do
      create(:post, scheduled_date: Date.tomorrow + 1.hour)
      expect(Post.tomorrows).not_to be_empty
    end

    it "should have :others post" do
      create(:post, scheduled_date: Date.tomorrow + 1.hour + 1.day)
      expect(Post.others).not_to be_empty
    end
  end
end
