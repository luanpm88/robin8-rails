require 'rails_helper'

RSpec.describe "pitches/show", type: :view do
  before(:each) do
    @pitch = assign(:pitch, Pitch.create!(
      :user_id => 1,
      :sent => false,
      :twitter_pitch => "MyText",
      :email_pitch => "MyText",
      :summary_length => 2,
      :email_address => "Email Address"
    ))
  end

  # it "renders attributes in <p>" do
  #   render
  #   expect(rendered).to match(/1/)
  #   expect(rendered).to match(/false/)
  #   expect(rendered).to match(/MyText/)
  #   expect(rendered).to match(/MyText/)
  #   expect(rendered).to match(/2/)
  #   expect(rendered).to match(/Email Address/)
  # end
end
