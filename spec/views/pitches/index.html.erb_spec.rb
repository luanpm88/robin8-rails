require 'rails_helper'

RSpec.describe "pitches/index", type: :view do
  before(:each) do
    assign(:pitches, [
      Pitch.create!(
        :user_id => 1,
        :sent => false,
        :twitter_pitch => "MyText",
        :email_pitch => "MyText",
        :summary_length => 2,
        :email_address => "Email Address"
      ),
      Pitch.create!(
        :user_id => 1,
        :sent => false,
        :twitter_pitch => "MyText",
        :email_pitch => "MyText",
        :summary_length => 2,
        :email_address => "Email Address"
      )
    ])
  end

  it "renders a list of pitches" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Email Address".to_s, :count => 2
  end
end
