require 'rails_helper'

RSpec.describe "MediaLists", type: :request do
  describe "GET /media_lists" do
    it "works! (now write some real specs)" do
      get media_lists_path
      expect(response).to have_http_status(200)
    end
  end
end
