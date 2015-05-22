require 'rails_helper'

describe Post do
  let!(:user) { stub_model(User, email: 'test@test.com', id: 1) }

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
end
