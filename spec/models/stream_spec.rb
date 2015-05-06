require 'spec_helper'
require 'rails_helper'

describe Stream do
  
  let(:user) { instance_double(User) }

  before(:each) do
    # user = mock(User)
    # user = mock_model(User)
    user.stub(:can_create_stream).and_return true 
  end

  it "requires a correct sort_column" do
    [nil, "", " "].each do |sort_column|
      stream = FactoryGirl.build(:stream, sort_column: sort_column)
      stream.should_not be_valid
    end
  end
end
