require 'rails_helper'

RSpec.describe "draft_pitches/index", type: :view do
  before(:each) do
    assign(:draft_pitches, [
      DraftPitch.create!(
        :twitter_pitch => "MyText",
        :email_pitch => "MyText",
        :summary_length => 1,
        :email_address => "Email Address",
        :release_id => 2,
        :email_subject => "Email Subject"
      ),
      DraftPitch.create!(
        :twitter_pitch => "MyText",
        :email_pitch => "MyText",
        :summary_length => 1,
        :email_address => "Email Address",
        :release_id => 2,
        :email_subject => "Email Subject"
      )
    ])
  end

  it "renders a list of draft_pitches" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Email Address".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Email Subject".to_s, :count => 2
  end
end
