
require 'rails_helper'

RSpec.describe "media_lists/edit", type: :view do
  before(:each) do
    @media_list = assign(:media_list, MediaList.create!(
      :name => "MyString",
      :user_id => 1
    ))
  end

  # it "renders the edit media_list form" do
  #   render

  #   assert_select "form[action=?][method=?]", media_list_path(@media_list), "post" do

  #     assert_select "input#media_list_name[name=?]", "media_list[name]"

  #     assert_select "input#media_list_user_id[name=?]", "media_list[user_id]"
  #   end
  # end
end
