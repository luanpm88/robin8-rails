require 'rails_helper'

RSpec.describe "contacts/new", type: :view do
  before(:each) do
    assign(:contact, Contact.new(
      :author_id => 1,
      :first_name => "MyString",
      :last_name => "MyString",
      :email => "MyString",
      :twitter_screen_name => "MyString"
    ))
  end

  it "renders new contact form" do
    render

    assert_select "form[action=?][method=?]", contacts_path, "post" do

      assert_select "input#contact_author_id[name=?]", "contact[author_id]"

      assert_select "input#contact_first_name[name=?]", "contact[first_name]"

      assert_select "input#contact_last_name[name=?]", "contact[last_name]"

      assert_select "input#contact_email[name=?]", "contact[email]"

      assert_select "input#contact_twitter_screen_name[name=?]", "contact[twitter_screen_name]"
    end
  end
end
