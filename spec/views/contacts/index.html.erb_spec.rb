require 'rails_helper'

RSpec.describe "contacts/index", type: :view do
  before(:each) do
    assign(:contacts, [
      Contact.create!(
        :author_id => 1,
        :first_name => "First Name",
        :last_name => "Last Name",
        :email => "Email",
        :twitter_screen_name => "Twitter Screen Name"
      ),
      Contact.create!(
        :author_id => 1,
        :first_name => "First Name",
        :last_name => "Last Name",
        :email => "Email",
        :twitter_screen_name => "Twitter Screen Name"
      )
    ])
  end

  it "renders a list of contacts" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Twitter Screen Name".to_s, :count => 2
  end
end
