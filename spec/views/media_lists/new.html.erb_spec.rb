require 'rails_helper'

RSpec.describe "media_lists/new", type: :view do
  before(:each) do
    assign(:media_list, MediaList.new(
      :name => "MyString",
      :user_id => 1
    ))
  end

  it "renders new media_list form" do
    render

    assert_select "form[action=?][method=?]", media_lists_path, "post" do

      assert_select "input#media_list_name[name=?]", "media_list[name]"

      assert_select "input#media_list_user_id[name=?]", "media_list[user_id]"
    end
  end
end
