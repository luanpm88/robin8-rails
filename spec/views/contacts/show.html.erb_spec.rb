require 'rails_helper'

RSpec.describe "contacts/show", type: :view do
  before(:each) do
    @contact = assign(:contact, Contact.create!(
      :author_id => 1,
      :first_name => "First Name",
      :last_name => "Last Name",
      :email => "Email",
      :twitter_screen_name => "Twitter Screen Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Twitter Screen Name/)
  end
end
