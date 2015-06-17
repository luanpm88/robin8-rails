require 'rails_helper'

RSpec.describe "media_lists/show", type: :view do
  before(:each) do
    @media_list = assign(:media_list, MediaList.create!(
      :name => "Name",
      :user_id => 1
    ))
  end

  # it "renders attributes in <p>" do
  #   render
  #   expect(rendered).to match(/Name/)
  #   expect(rendered).to match(/1/)
  # end
end
