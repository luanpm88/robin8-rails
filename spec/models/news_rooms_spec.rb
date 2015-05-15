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
  end

end
