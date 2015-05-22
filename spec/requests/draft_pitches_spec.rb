require 'rails_helper'

RSpec.describe "DraftPitches", type: :request do
  describe "GET /draft_pitches" do
    it "works! (now write some real specs)" do
      get draft_pitches_path
      expect(response).to have_http_status(200)
    end
  end
end
