require 'rails_helper'

RSpec.describe TextapiController, type: :controller do

  describe "GET #classify" do
    it "returns http success" do
      get :classify
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #concepts" do
    it "returns http success" do
      get :concepts
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #summarize" do
    it "returns http success" do
      get :summarize
      expect(response).to have_http_status(:success)
    end
  end

end
