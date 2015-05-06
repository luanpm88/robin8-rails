require 'spec_helper'
require 'rails_helper'

describe Stream do
  
  let(:user) { stub_model(User, :email => 'test@test.com', id: 1) }

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

  it "requires a correct sort_column" do
    ["published_at", "shares_count"].each do |sort_column|
      stream = FactoryGirl.build(:stream, sort_column: sort_column)
      stream.user = user
      stream.should be_valid
    end
  end
end
