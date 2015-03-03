require 'rails_helper'

RSpec.describe "media_lists/index", type: :view do
  before(:each) do
    assign(:media_lists, [
      MediaList.create!(
        :name => "Name",
        :user_id => 1
      ),
      MediaList.create!(
        :name => "Name",
        :user_id => 1
      )
    ])
  end

  it "renders a list of media_lists" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
