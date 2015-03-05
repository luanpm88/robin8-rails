require 'rails_helper'

RSpec.describe AutocompletesController, type: :controller do

  describe "GET #locations" do
    it "returns http success" do
      get :locations
      expect(response).to have_http_status(:success)
    end
  end

end
