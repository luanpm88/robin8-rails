require 'rails_helper'

RSpec.describe "draft_pitches/show", type: :view do
  before(:each) do
    @draft_pitch = assign(:draft_pitch, DraftPitch.create!(
      :twitter_pitch => "MyText",
      :email_pitch => "MyText",
      :summary_length => 1,
      :email_address => "Email Address",
      :release_id => 2,
      :email_subject => "Email Subject"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Email Address/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Email Subject/)
  end
end
