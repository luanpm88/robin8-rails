require 'spec_helper'
require 'rails_helper'

describe Stream do
  
  let(:user) { stub_model(User, :email => 'test@test.com', id: 1) }

  describe "create new stream" do
    before(:each) do
      allow(user).to receive(:can_create_stream).and_return(true)
    end

    it "requires a correct sort_column" do
      [nil, "", " "].each do |sort_column|
        stream = FactoryGirl.build(:stream, sort_column: sort_column)
        stream.user = user
        stream.should_not be_valid
      end
    end

    it "requires a correct sort_column(bad value)" do
      ["published_at", "shares_count"].each do |sort_column|
        stream = FactoryGirl.build(:stream, sort_column: sort_column)
        stream.user = user
        stream.should be_valid
      end
    end

    it "requires a correct position" do
      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.user = user
      stream.save

      stream.should be_valid
    end

    it "requires a position 1" do
      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.user = user
      stream.position.should == 1
    end

    it "requires a position 2" do
      stream = FactoryGirl.build(:stream, sort_column: 'published_at', name: 'first')
      stream.user = user
      stream.save
      p stream

      stream2 = FactoryGirl.build(:stream, sort_column: 'published_at', name: 'second')
      stream2.user = user
      p stream2
      stream2.position.should == 2
    end

    it "requires a correct position(bad value)" do
      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.position = 0
      stream.user = user
      stream.should be_valid
    end

    it "'s user should have available streams count" do
      allow(user).to receive(:can_create_stream).and_return(false)

      stream = FactoryGirl.build(:stream, sort_column: 'published_at')
      stream.user = user
      stream.should_not be_valid
    end
  end

  describe "update new stream" do

  end
end
