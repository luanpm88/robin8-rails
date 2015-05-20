require 'rails_helper'

RSpec.describe "draft_pitches/new", type: :view do
  before(:each) do
    assign(:draft_pitch, DraftPitch.new(
      :twitter_pitch => "MyText",
      :email_pitch => "MyText",
      :summary_length => 1,
      :email_address => "MyString",
      :release_id => 1,
      :email_subject => "MyString"
    ))
  end

  it "renders new draft_pitch form" do
    render

    assert_select "form[action=?][method=?]", draft_pitches_path, "post" do

      assert_select "textarea#draft_pitch_twitter_pitch[name=?]", "draft_pitch[twitter_pitch]"

      assert_select "textarea#draft_pitch_email_pitch[name=?]", "draft_pitch[email_pitch]"

      assert_select "input#draft_pitch_summary_length[name=?]", "draft_pitch[summary_length]"

      assert_select "input#draft_pitch_email_address[name=?]", "draft_pitch[email_address]"

      assert_select "input#draft_pitch_release_id[name=?]", "draft_pitch[release_id]"

      assert_select "input#draft_pitch_email_subject[name=?]", "draft_pitch[email_subject]"
    end
  end
end
