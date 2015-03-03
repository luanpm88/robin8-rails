require 'rails_helper'

RSpec.describe "pitches/new", type: :view do
  before(:each) do
    assign(:pitch, Pitch.new(
      :user_id => 1,
      :sent => false,
      :twitter_pitch => "MyText",
      :email_pitch => "MyText",
      :summary_length => 1,
      :email_address => "MyString"
    ))
  end

  it "renders new pitch form" do
    render

    assert_select "form[action=?][method=?]", pitches_path, "post" do

      assert_select "input#pitch_user_id[name=?]", "pitch[user_id]"

      assert_select "input#pitch_sent[name=?]", "pitch[sent]"

      assert_select "textarea#pitch_twitter_pitch[name=?]", "pitch[twitter_pitch]"

      assert_select "textarea#pitch_email_pitch[name=?]", "pitch[email_pitch]"

      assert_select "input#pitch_summary_length[name=?]", "pitch[summary_length]"

      assert_select "input#pitch_email_address[name=?]", "pitch[email_address]"
    end
  end
end
